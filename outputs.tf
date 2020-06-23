output "ilb_dns" {
  description = "DNS name follows GCP internal rule SERVICE_LABEL.FORWARDING_RULE_NAME.il4.REGION.lb.PROJECT_ID.internal"
  value       = "es-ilb.${google_compute_forwarding_rule.elasticsearch.name}.il7.${var.region}.lb.${var.project}.internal"
}

output "ip_address" {
  description = "The internal IP assigned to the regional forwarding rule."
  value       = google_compute_forwarding_rule.elasticsearch.ip_address
}

