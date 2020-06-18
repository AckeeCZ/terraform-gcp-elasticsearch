resource "google_compute_firewall" "elasticsearch_allow_healthchecks" {
  name     = "elasticsearch-gcp-health-check"
  network  = var.network
  priority = 1000

  source_ranges = [
    # all the subnets for GCP health checks
    "35.191.0.0/16", "130.211.0.0/22", "35.191.0.0/16", "209.85.152.0/22", "209.85.204.0/22"
  ]

  allow {
    protocol = "tcp"
  }

  target_tags = ["elasticsearch"]
  direction   = "INGRESS"
}

resource "google_compute_firewall" "elasticsearch_allow_ilb_traffic" {
  name     = "elasticsearch-gce-traffic"
  network  = var.network
  priority = 1000

  source_ranges = [
    "192.168.0.0/16",  # internal load balancer subnet used for traffic towards GCE instances
  ]

  allow {
    protocol = "tcp"
  }

  target_tags = ["elasticsearch"]
  direction   = "INGRESS"
}

resource "google_compute_firewall" "elasticsearch_allow_external_subnets" {
  for_each = length(var.allowed_ipv4_subnets) > 0 ? {allowed_ipv4_subnets: var.allowed_ipv4_subnets} : {}
  name     = "elasticsearch-gcp-gke-communication"
  network  = var.network
  priority = 1000

  source_ranges = each.value

  allow {
    protocol = "tcp"
  }

  target_tags = ["elasticsearch"]
  direction   = "INGRESS"
}

resource "google_compute_firewall" "elasticsearch_allow_external_tags" {
  for_each = length(var.allowed_tags) > 0 ? {allowed_tags: var.allowed_tags} : {}
  name     = "elasticsearch-gcp-gke-communication"
  network  = var.network
  priority = 1000

  source_tags = each.value

  allow {
    protocol = "tcp"
  }

  target_tags = ["elasticsearch"]
  direction   = "INGRESS"
}
