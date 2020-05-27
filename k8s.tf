# k8s code resources created mainly for git@github.com:AckeeCZ/goproxie.git compatibility

resource "kubernetes_endpoints" "endpoint" {

  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
    labels = {
      app = "elasticsearch-endpoints"
    }
  }

  subset {
    address {
      ip = google_compute_forwarding_rule.elasticsearch.ip_address
    }

    port {
      port = 80
    }
  }
}

resource "kubernetes_service" "elasticsearch" {

  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
  }

  spec {
    type = "NodePort"
    port {
      port        = 9200
      target_port = 80
    }
    selector = {
      app = "elasticsearch-endpoints"
    }
  }
}

resource "kubernetes_pod" "elasticsearch" {
  metadata {
    name      = "elasticsearch"
    namespace = var.namespace
  }

  spec {
    container {
      name  = "proxy-tcp"
      image = "k8s.gcr.io/proxy-to-service:v2"
      args = [
        "tcp",
        "9200",
        "elasticsearch",
      ]
      port {
        protocol       = "TCP"
        container_port = 9200
        host_port      = 9200
      }
    }
  }
}
