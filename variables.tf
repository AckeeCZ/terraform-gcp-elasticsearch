variable "project" {
  description = "Name of GCP project."
  type        = string
}

variable "region" {
  description = "Region of GCP project."
  type        = string
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
  type        = string
}

variable "cluster_name" {
  description = "ES cluster name."
  type        = string
}

variable "raw_image_source" {
  description = "URL of tar archive containing RAW source for ES image (you can use Packer image template to generate image, as mentioned above)."
  default     = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"
  type        = string
}

variable "data_disk_type" {
  description = "Type of disk used as a persistent storage."
  default     = "pd-ssd"
  type        = string
}

variable "data_disk_size" {
  description = "Persistent disk size specified in GB."
}

variable "k8s_enable" {
  description = "Enable k8s extension to deploy endpoints to cluster members and internal load balancer as a k8s service"
  type        = bool
  default     = false
}

variable "k8s_namespace" {
  default     = "production"
  description = "K8s namespace used to deploy endpoints and services."
  type        = string
}
