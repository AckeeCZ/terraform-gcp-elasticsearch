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
  source            = "./.."
  project           = var.project
  region            = var.region
  zone              = var.zone
  instance_name     = "elasticsearch-prod"
  cluster_name      = "elasticsearch"
  cluster_ipv4_cidr = module.gke.cluster_ipv4_cidr
  node_count        = "1"
  heap_size         = "1500m"
  raw_image_source  = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"
  data_disk_size    = "10"
  k8s_enable        = true
  namespace         = var.namespace
}

module "gke" {
  source            = "git::ssh://git@gitlab.ack.ee/Infra/terraform-gke-vpc.git?ref=v6.2.0"
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

output "es_dns" {
  value = module.elasticsearch_prod.elasticsearch_dns
}

output "es_ip" {
  value = module.elasticsearch_prod.ip_address
}
