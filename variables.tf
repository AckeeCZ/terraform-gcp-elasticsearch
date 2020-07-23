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
  type        = string
}

variable "instance_name" {
  description = "Base for GCE instances name. Must be unique within GCP project"
  type        = string
}

variable "allowed_ipv4_subnets" {
  description = "IPv4 subnets allowed to communicate with ES instances."
  type        = list(string)
  default     = []
}

variable "allowed_tags" {
  description = "Network tags allowed to communicate with ES instances."
  type        = list(string)
  default     = []
}

variable "node_count" {
  description = "Number of ES nodes to deploy."
  default     = 1
  type        = number
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
  type        = string
}

variable "namespace" {
  default     = "production"
  description = "K8s namespace used to deploy endpoints and services."
  type        = string
}

variable "network" {
  description = "GCE VPC used for compute instances"
  default     = "default"
  type        = string
}

variable "load_balancer_subnetwork" {
  description = "The subnetwork that the load balanced IP should belong to for this Forwarding Rule. If the network specified is in auto subnet mode, this field is optional. However, if the network is in custom subnet mode, a subnetwork must be specified."
  default     = "10.64.0.0/26"
  type        = string
}

variable "cluster_ca_certificate" {
  description = "Public CA certificate that is the root of trust for the GKE K8s cluster"
  type        = string
}

variable "cluster_user" {
  description = "Cluster master username, keep always secret!"
  type        = string
}

variable "cluster_password" {
  description = "Cluster master password, keep always secret!"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster control plane endpoint"
  type        = string
}

variable "add_suffix" {
  description = "Add random suffix to all resources that will prevent more instances of this module to be provisioned"
  default     = false
  type        = bool
}
