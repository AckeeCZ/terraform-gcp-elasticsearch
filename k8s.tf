resource "kubernetes_endpoints" "node" {
  count = var.k8s_enable ? 1 : 0

  metadata {
    name      = "elasticsearch"
    namespace = var.k8s_namespace
  }

  subset {
    dynamic "address" {
      for_each = google_compute_instance.elasticsearch
      content {
        ip = address.value.network_interface.0.network_ip
      }
    }

    port {
      port = 9200
    }
  }
}

resource "kubernetes_service" "elasticsearch" {
  count = var.k8s_enable ? 1 : 0

  metadata {
    name      = "elasticsearch"
    namespace = var.k8s_namespace
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal"
    }
  }

  spec {
    port {
      port        = 9200
      target_port = 9200
    }
  }
}

