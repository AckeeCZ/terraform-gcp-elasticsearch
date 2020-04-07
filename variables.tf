variable "project" {
  description = "Name of GCP project."
}

variable "region" {
  description = "Region of GCP project."
}

variable "zone" {
  description = "Zone of GCP project - optional parameter, if not set, the instances will be spread across the available zones."
  default     = null
}

variable "instance_name" {
  description = "Base for GCE instances name."
}

variable "cluster_ipv4_cidr" {
  description = "IPv4 CIDR of k8s cluster used for ES communication."
}

variable "node_count" {
  description = "Number of ES nodes to deploy."
  default     = "1"
}

variable "heap_size" {
  description = "Heap size setting for ES."
  default     = "1800m"
}

variable "cluster_name" {
  description = "ES cluster name."
}

variable "raw_image_source" {
  description = "URL of tar archive containing RAW source for ES image (you can use Packer image template to generate image, as mentioned above)."
  default     = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"
}

variable "data_disk_type" {
  description = "Type of disk used as a persistent storage."
  default     = "pd-ssd"
}

variable "data_disk_size" {
  description = "Persistent disk size specified in GB."
}

variable "k8s_endpoint" {
  description = "K8s endpoint, e.g. IP address or host used to deploy endpoints and services."
}

variable "k8s_user" {
  description = "K8s user used to deploy endpoints and services."
}

variable "k8s_password" {
  description = "K8s password used to deploy endpoints and services."
}

variable "k8s_ca_certificate" {
  description = "K8s CA certificate used for auth to deploy endpoints and services."
}

variable "k8s_namespace" {
  default     = "production"
  description = "K8s namespace used to deploy endpoints and services."
}
