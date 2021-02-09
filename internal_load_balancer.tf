locals {
  ilb_dns = "es-ilb.${google_compute_forwarding_rule.elasticsearch.name}.il4.${var.region}.lb.${var.project}.internal"
}

data "google_compute_network" "default" {
  name    = var.network
  project = var.project
}

resource "google_compute_subnetwork" "proxy" {
  provider = google-beta

  name          = "elasticsearch-net-proxy${local.suffix}"
  ip_cidr_range = var.load_balancer_subnetwork
  region        = var.region
  network       = data.google_compute_network.default.id
  purpose       = "PRIVATE"
  role          = "ACTIVE"
}

resource "google_compute_forwarding_rule" "elasticsearch" {
  provider = google-beta

  all_ports = true

  name = "elasticsearch-forwarding-rule${local.suffix}"

  network    = data.google_compute_network.default.self_link
  subnetwork = google_compute_subnetwork.proxy.id

  load_balancing_scheme = "INTERNAL"
  ip_protocol           = "TCP"

  region          = var.region
  backend_service = google_compute_region_backend_service.elasticsearch.id

  # used as DNS reference in internal GCE DNS system, service without label do not get DNS name
  service_label = "es-ilb"
}

resource "google_compute_instance_group" "elasticsearch" {
  provider = google-beta

  name        = var.zone != null ? "elasticsearch-instance-pool-${var.zone}${local.suffix}" : "elasticsearch-instance-pool-${data.google_compute_zones.available.names[count.index]}${local.suffix}"
  description = var.zone != null ? "Elasticsearch instance pool ${var.zone}${local.suffix}" : "Elasticsearch instance pool ${data.google_compute_zones.available.names[count.index]}${local.suffix}"
  zone        = var.zone != null ? var.zone : data.google_compute_zones.available.names[count.index]
  count       = var.zone != null ? 1 : var.node_count < local.zone_count ? var.node_count : local.zone_count

  instances = var.zone == null ? [
    # filter out the instances based on their location in the zones
    for i in google_compute_instance.elasticsearch : i.self_link if
    # google_compute_instance.elasticsearch does not reference the zone of instance, instead the zone is known
    # by the order of the instances created by count attribute
    data.google_compute_zones.available.names[
      index(google_compute_instance.elasticsearch, i) % local.zone_count
    ] == data.google_compute_zones.available.names[count.index]
    ] : [
    # all instances belong to one instance group in one zone
    for i in google_compute_instance.elasticsearch : i.self_link
  ]

  named_port {
    # set here for backend setting purpouses, l7 internal load balancer does not accept any other port name
    name = "http"
    port = "9200"
  }

  named_port {
    name = "elasticsearch-transport"
    port = "9300"
  }
}

resource "google_compute_health_check" "elasticsearch" {
  provider = google-beta

  name               = "elasticsearch-healthcheck${local.suffix}"
  check_interval_sec = 1
  timeout_sec        = 1
  tcp_health_check {
    port = "9200"
  }
}

resource "google_compute_region_backend_service" "elasticsearch" {
  provider = google-beta

  name                  = "elasticsearch-lb${local.suffix}"
  protocol              = "TCP"
  timeout_sec           = 30
  load_balancing_scheme = "INTERNAL"

  region = var.region

  dynamic "backend" {
    for_each = google_compute_instance_group.elasticsearch
    content {
      group = backend.value.self_link
    }
  }

  health_checks = [google_compute_health_check.elasticsearch.self_link]
}



