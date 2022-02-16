# k8s code resources created mainly for git@github.com:AckeeCZ/goproxie.git compatibility

resource "kubernetes_stateful_set" "elasticsearch" {
  metadata {

    labels = {
      app = "elasticsearch"
    }

    namespace = var.namespace
    name      = "elasticsearch${local.suffix}"
  }

  spec {
    selector {
      match_labels = {
        external-app = "elasticsearch${local.suffix}"
      }
    }

    service_name = "elasticsearch${local.suffix}"

    template {
      metadata {
        labels = {
          external-app = "elasticsearch${local.suffix}"
        }
      }

      spec {
        container {
          name              = "elasticsearch${local.suffix}"
          image             = "alpine/socat"
          image_pull_policy = "IfNotPresent"

          args = [
            "tcp-listen:9200,fork,reuseaddr",
            "tcp-connect:${google_compute_forwarding_rule.elasticsearch.ip_address}:9200",
          ]
          port {
            protocol       = "TCP"
            container_port = 9200
            host_port      = 9200
          }
          resources {
            limits = {
              cpu    = "100m"
              memory = "100Mi"
            }
            requests = {
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
