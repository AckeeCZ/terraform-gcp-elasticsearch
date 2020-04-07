provider "kubernetes" {
  version = "~> 1.11.0"

  load_config_file = false
  host             = "https://${var.k8s_endpoint}"

  username = var.k8s_user
  password = var.k8s_password

  cluster_ca_certificate = var.k8s_ca_certificate
}

provider "google" {
  version = "~> 2.20.0"
}

provider "google-beta" {
  version = "~> 3.6"
}
