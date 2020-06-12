# k8s code resources created mainly for git@github.com:AckeeCZ/goproxie.git compatibility

resource "kubernetes_endpoints" "endpoint" {

  metadata {
    name      = "elasticsearch-loadbalancer"
    namespace = var.namespace
    labels = {
      app = "elasticsearch-endpoints-loadbalancer"
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
    name      = "elasticsearch-loadbalancer"
    namespace = var.namespace
  }

  spec {
    type = "NodePort"
    port {
      port        = 9200
      target_port = 80
    }
    selector = {
      app = "elasticsearch-endpoints-loadbalancer"
    }
  }
  depends_on = [kubernetes_endpoints.endpoint]
}

resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {

    labels = {
      app = "elasticsearch"
    }

    namespace = var.namespace
    name      = "elasticsearch"
  }

  spec {
    selector {
      match_labels = {
        external-app = "elasticsearch"
      }
    }

    service_name = "elasticsearch"

    template {
      metadata {
        labels = {
          external-app = "elasticsearch"
        }
      }

      spec {
        container {
          name              = "elasticsearch"
          image             = "k8s.gcr.io/proxy-to-service:v2"
          image_pull_policy = "IfNotPresent"

          args = [
            "tcp",
            "9200",
            "elasticsearch-loadbalancer",
          ]
          port {
            protocol       = "TCP"
            container_port = 9200
            host_port      = 9200
          }
          resources {
            limits {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests {
              cpu    = "10m"
              memory = "10Mi"
            }
          }
        }
        termination_grace_period_seconds = 1
      }
    }
    update_strategy {
      type = "RollingUpdate"
      rolling_update {
        partition = 0
      }
    }
  }
}
