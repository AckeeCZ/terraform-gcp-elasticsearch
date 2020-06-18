provider "template" {
  version = "~> 2.1.2"
}

provider "tls" {
  version = "~> 2.1.1"
}

provider "google" {
  project = var.project
  region  = var.zone
}

provider "google-beta" {
  project = var.project
  region  = var.zone
}

module "elasticsearch_prod" {
  source           = "./.."
  project          = var.project
  region           = var.region

  instance_name    = "elasticsearch-prod"
  cluster_name     = "elasticsearch"
  node_count       = 2
  heap_size        = "1500m"
  raw_image_source = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"
  data_disk_size   = "10"

  namespace         = var.namespace

  cluster_ca_certificate = module.gke.cluster_ca_certificate
  cluster_user           = module.gke.cluster_username
  cluster_pass           = module.gke.cluster_password
  cluster_endpoint       = module.gke.endpoint
}

module "gke" {
  source            = "git::ssh://git@gitlab.ack.ee/Infra/terraform-gke-vpc.git?ref=v6.4.0"
  namespace         = var.namespace
  project           = var.project
  location          = var.zone
  vault_secret_path = var.vault_secret_path
  private           = false
  min_nodes         = 1
  max_nodes         = 1
  cluster_name      = "es-service-test"
}

variable "namespace" {
  default = "stage"
}

variable "project" {
}

variable "vault_secret_path" {
}

variable "region" {
  default = "europe-west3"
}

variable "zone" {
  default = "europe-west3-c"
}

output "ip_address" {
  value = module.elasticsearch_prod.ip_address
}

output "ilb_dns" {
  value = module.elasticsearch_prod.ilb_dns
}
