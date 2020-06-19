data "google_compute_network" "default" {
  name = var.network
}

resource "google_compute_region_target_http_proxy" "elasticsearch" {
  provider = google-beta

  region  = var.region
  name    = "es-backend-proxy"
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_region_url_map" "default" {
  provider = google-beta

  region = var.region
  # url map name is displayed as load balancer name, this name maybe misleading
  name            = "es-ilb"
  default_service = google_compute_region_backend_service.elasticsearch.id
}


resource "google_compute_forwarding_rule" "elasticsearch" {
  provider = google-beta

  all_ports              = false
  allow_global_access    = false
  is_mirroring_collector = false

  name = "elasticsearch-forwarding-rule"

  network    = data.google_compute_network.default.self_link
  port_range = "80-80"

  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_protocol           = "TCP"

  region = var.region
  target = google_compute_region_target_http_proxy.elasticsearch.self_link

  # used as DNS reference in internal GCE DNS system, service without label do not get DNS name
  service_label = "es-ilb"
}

resource "google_compute_instance_group" "elasticsearch" {
  provider    = google-beta
  name        = var.zone != null ? "elasticsearch-instance-pool-${var.zone}" : "elasticsearch-instance-pool-${data.google_compute_zones.available.names[count.index]}"
  description = var.zone != null ? "Elasticsearch instance pool ${var.zone}" : "Elasticsearch instance pool ${data.google_compute_zones.available.names[count.index]}"
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

resource "google_compute_region_health_check" "elasticsearch" {
  provider           = google-beta
  name               = "elasticsearch-healthcheck"
  check_interval_sec = 5
  timeout_sec        = 5
  region             = var.region

  http_health_check {
    port = "9200"
  }
  log_config {
    enable = true
  }
}


resource "google_compute_region_backend_service" "elasticsearch" {
  provider              = google-beta
  name                  = "elasticsearch-lb"
  protocol              = "HTTP"
  timeout_sec           = 30
  load_balancing_scheme = "INTERNAL_MANAGED"

  region = var.region

  connection_draining_timeout_sec = 300
  locality_lb_policy              = "ROUND_ROBIN"

  dynamic "backend" {
    for_each = google_compute_instance_group.elasticsearch
    content {
      balancing_mode        = "RATE"
      capacity_scaler       = 1
      failover              = false
      group                 = backend.value.self_link
      max_rate_per_instance = 100
    }
  }

  health_checks = [google_compute_region_health_check.elasticsearch.self_link]
}



