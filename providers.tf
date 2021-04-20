provider "kubernetes" {
  host                   = "https://${var.cluster_endpoint}"
  token                  = var.cluster_token
  cluster_ca_certificate = var.cluster_ca_certificate
}
