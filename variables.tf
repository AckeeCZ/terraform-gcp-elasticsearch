variable "project" {}
variable "zone" {}
variable "instance_name" {}
variable "cluster_ipv4_cidr" {}

variable "node_count" {
  default = "1"
}
variable "heap_size" {
  default = "1800m"
}
variable "cluster_name" {}
variable "raw_image_source" {
  default = "https://storage.googleapis.com/ackee-images/es6-gce-discovery-disk-latest.tar.gz"
}