data "google_compute_network" "default" {
  name = var.network
}

resource "google_compute_subnetwork" "elastic_lb_subnet" {
  name          = "es-load-balancer-subnetwork"
  ip_cidr_range = "192.168.254.0/24"
  region        = var.region
  network       = data.google_compute_network.default.self_link
}

resource "google_compute_region_target_http_proxy" "elasticsearch" {
  provider = google-beta

  region  = var.region
  name    = "es-backend-proxy"
  url_map = google_compute_region_url_map.default.id
}

resource "google_compute_region_url_map" "default" {
  provider = google-beta

  region          = var.region
  name            = "es-backend-map"
  default_service = google_compute_region_backend_service.elasticsearch.id
}


resource "google_compute_forwarding_rule" "elasticsearch" {
  provider = google-beta

  all_ports              = false
  allow_global_access    = false
  is_mirroring_collector = false


  name = "elasticsearch-forwarding-rule"

  network = data.google_compute_network.default.self_link

  port_range = "80-80"

  load_balancing_scheme = "INTERNAL_MANAGED"
  ip_protocol           = "TCP"

  # backend_service = google_compute_region_backend_service.elasticsearch.self_link
  region = var.region

  target = google_compute_region_target_http_proxy.elasticsearch.self_link
}


resource "google_compute_instance_group" "elasticsearch" {
  provider    = google-beta
  name        = "elasticsearch-instance-pool"
  description = "Elasticsearch instance pool"
  zone        = var.zone

  instances = [
    for i in google_compute_instance.elasticsearch : i.self_link
  ]

  named_port {
    name = "http"  # set here for backend setting purpouses
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


  backend {
    balancing_mode        = "RATE"
    capacity_scaler       = 1
    failover              = false
    group                 = google_compute_instance_group.elasticsearch.self_link
    max_rate_per_instance = 100
  }

  log_config {
    enable      = true
    sample_rate = 1
  }

  health_checks = [google_compute_region_health_check.elasticsearch.self_link]
}



