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


resource "google_compute_firewall" "elasticsearch_allow_external_cluster_cidr" {
  name     = "elasticsearch-gcp-gke-communication"
  network  = var.network
  priority = 1000

  source_ranges = [
    var.cluster_ipv4_cidr,
  ]

  allow {
    protocol = "tcp"
  }

  target_tags = ["elasticsearch"]
  direction   = "INGRESS"
}


resource "google_compute_firewall" "elasticsearch_allow_cluster" {
  name     = "elasticsearch-allow-cluster-${var.instance_name}"
  network  = var.network
  priority = 1000

  allow {
    protocol = "tcp"
    ports    = ["9200", "9300"]
  }

  source_ranges = [var.cluster_ipv4_cidr]
  source_tags   = ["elasticsearch"]
}
