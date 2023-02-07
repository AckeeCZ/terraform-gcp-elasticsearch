module "elasticsearch_prod" {
  source  = "./.."
  project = var.project
  region  = var.region
  zone    = var.zone

  instance_name          = "elasticsearch-prod"
  cluster_name           = "elasticsearch"
  node_count             = 2
  heap_size              = "1500m"
  raw_image_source       = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-8-disk-1651069402.tar.gz"
  data_disk_size         = "10"
  root_disk_size         = "20"
  backup_repository_name = "${var.project}-es1-backups"

  namespace = var.namespace

  cluster_ca_certificate = module.gke.cluster_ca_certificate
  cluster_token          = module.gke.access_token
  cluster_endpoint       = module.gke.endpoint

  allowed_ipv4_subnets = ["10.20.0.0/14"]
}

module "elasticsearch_second_prod" {
  source  = "./.."
  project = var.project
  region  = var.region

  instance_name = "elasticsearch-prod-2"
  cluster_name  = "elasticsearch-2"
  node_roles = {
    0 = "master",
    2 = "data,master"
  }
  node_count               = 3
  heap_size                = "1500m"
  raw_image_source         = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-8-disk-1651069402.tar.gz"
  data_disk_size           = "10"
  root_disk_size           = "20"
  backup_repository_name   = "${var.project}-es-manual-backups"
  backup_repository_create = false

  namespace = var.namespace

  cluster_ca_certificate = module.gke.cluster_ca_certificate
  cluster_token          = module.gke.access_token
  cluster_endpoint       = module.gke.endpoint

  allowed_ipv4_subnets = ["10.20.0.0/14"]
  add_random_suffix    = true

  load_balancer_subnetwork = "192.168.254.0/24"
}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 2.0"
  project_id    = var.project
  region        = var.region
  create_router = true
  network       = "default"
  router        = "nat-router"
}

module "gke" {
  source                  = "AckeeCZ/vpc/gke"
  version                 = "11.11.0"
  namespace               = var.namespace
  project                 = var.project
  location                = var.zone
  vault_secret_path       = var.vault_secret_path
  private                 = true
  min_nodes               = 2
  max_nodes               = 2
  cluster_name            = "es-service-test"
  enable_sealed_secrets   = false
  cluster_ipv4_cidr_block = "10.20.0.0/14"
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
