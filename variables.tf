variable "project" {}
variable "zone" {}
variable "mem" {
	default = "2g"
}
variable "instance_name" {}
variable "cluster_ipv4_cidr" {}

variable "node_count" {
  default = "1"
}
variable "heap_size" {
  default = "1800m"
}
variable "cluster_name" {}