resource "google_storage_bucket" "backup_repository" {
  name          = local.backup_repository
  location      = var.region
  storage_class = var.backup_storage_class
  force_destroy = true
  count         = var.backup_repository_create ? 1 : 0
}

resource "kubernetes_cron_job_v1" "backup_cleanup" {
  metadata {
    name = "elasticsearch-backup${local.suffix}"
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = var.backup_failed_jobs_history_limit
    schedule                      = var.backup_schedule
    successful_jobs_history_limit = var.backup_successful_jobs_history_limit
    job_template {
      metadata {}
      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10
        template {
          metadata {}
          spec {
            container {
              name  = "elasticsearch-backup-cleanup"
              image = "curlimages/curl"
              command = [
                "/bin/sh",
                "-c",
                "curl -s -XPOST http://${google_compute_forwarding_rule.elasticsearch.ip_address}:9200/_snapshot/${local.backup_repository}/_cleanup?pretty"
              ]
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}
