provider "template" {
  version = "~> 2.2.0"
}

provider "tls" {
  version = "~> 3.0.0"
}

provider "random" {
  version = "~> 3.0.0"
}

provider "vault" {
  version = "~> 2.18.0"
}

provider "google" {
  version = "~> 3.56.0"
  project = var.project
  region  = var.zone
}

provider "google-beta" {
  version = "~> 3.56.0"
  project = var.project
  region  = var.zone
}

provider "kubernetes" {
  version = "~> 1.13.2"
}

provider "helm" {
  version = "~> 1.3.0"
}

module "elasticsearch_prod" {
  source  = "./.."
  project = var.project
  region  = var.region
  zone    = var.zone

  instance_name          = "elasticsearch-prod"
  cluster_name           = "elasticsearch"
  node_count             = 2
  heap_size              = "1500m"
  raw_image_source       = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-16.tar.gz"
  data_disk_size         = "10"
  root_disk_size         = "20"
  backup_repository_name = "${var.project}-es1-backups"

  namespace = var.namespace

  cluster_ca_certificate = module.gke.cluster_ca_certificate
  cluster_token          = module.gke.cluster_token
  cluster_endpoint       = module.gke.endpoint

  allowed_ipv4_subnets = [module.gke.cluster_ipv4_cidr]
}

module "elasticsearch_second_prod" {
  source  = "./.."
  project = var.project
  region  = var.region

  instance_name            = "elasticsearch-prod-2"
  cluster_name             = "elasticsearch-2"
  node_count               = 2
  heap_size                = "1500m"
  raw_image_source         = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-16.tar.gz"
  data_disk_size           = "10"
  root_disk_size           = "20"
  backup_repository_name   = "${var.project}-es-manual-backups"
  backup_repository_create = false

  namespace = var.namespace

  cluster_ca_certificate = module.gke.cluster_ca_certificate
  cluster_token          = module.gke.cluster_token
  cluster_endpoint       = module.gke.endpoint

  allowed_ipv4_subnets = [module.gke.cluster_ipv4_cidr]
  add_random_suffix    = true

  load_balancer_subnetwork = "192.168.254.0/24"
}

module "gke" {
  source                = "AckeeCZ/vpc/gke"
  version               = "9.0.0"
  namespace             = var.namespace
  project               = var.project
  location              = var.zone
  vault_secret_path     = var.vault_secret_path
  private               = false
  min_nodes             = 1
  max_nodes             = 1
  cluster_name          = "es-service-test"
  enable_sealed_secrets = false
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


output "ip_address_with_suffix" {
  value = module.elasticsearch_second_prod.ip_address
}

output "ilb_dns_with_suffix" {
  value = module.elasticsearch_second_prod.ilb_dns
}
