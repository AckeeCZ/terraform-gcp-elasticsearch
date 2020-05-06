output "elasticsearch_dns" {
  description = "DNS name follows GCP internal rule SERVICE_LABEL.FORWARDING_RULE_NAME.il4.REGION.lb.PROJECT_ID.internal"
  value = "${google_compute_region_backend_service.elasticsearch.name}.${google_compute_forwarding_rule.elasticsearch.name}.il4.${var.region}.lb.${var.project}.internal"
}

output "ip_address" {
  description = "The internal IP assigned to the regional forwarding rule."
  value       = google_compute_forwarding_rule.elasticsearch.ip_address
}
