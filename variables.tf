variable "project" {
}

variable "region" {
}

variable "instance_name" {
}

variable "cluster_ipv4_cidr" {
}

variable "node_count" {
  default = "1"
}

variable "heap_size" {
  default = "1800m"
}

variable "cluster_name" {
}

variable "raw_image_source" {
}

variable "data_disk_type" {
  default = "pd-ssd"
}

variable "data_disk_size" {
}
