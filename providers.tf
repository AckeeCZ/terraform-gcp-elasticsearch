provider "kubernetes" {
  version                = "~> 1.11.0"
  load_config_file       = false
  host                   = "https://${var.cluster_endpoint}"
  username               = var.cluster_user
  password               = var.cluster_password
  cluster_ca_certificate = var.cluster_ca_certificate
}
