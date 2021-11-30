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

variable "root_disk_size" {
  description = "Persistent disk size specified in GB."
  default     = "10"
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

variable "cluster_token" {
  description = "Cluster master token, keep always secret!"
  type        = string
}

variable "cluster_endpoint" {
  description = "Cluster control plane endpoint"
  type        = string
}

variable "add_random_suffix" {
  description = "Add random suffix to all resources with possible duplicates if the same module is deployed multiple times"
  default     = false
  type        = bool
}

variable "machine_type" {
  description = "The machine type to create"
  default     = "n1-standard-1"
  type        = string
}

variable "backup_repository_name" {
  description = "Custom name of Elasticsearch backup repository, same name is going to be used for backup bucket"
  type        = string
  default     = ""
}

variable "backup_repository_create" {
  description = "If GCS bucket should be created. Set to false, if you previously created bucket "
  default     = true
  type        = bool
}

variable "custom_init_commands" {
  description = "Any custom commands which should be run after bootstrapping the Elasticsearch cluster after starting Elasticsearch service"
  default     = ""
  type        = string
}

variable "custom_pre_start_commands" {
  description = "Any custom commands which should be run after bootstrapping the Elasticsearch cluster before starting Elasticsearch service"
  default     = ""
  type        = string
}

variable "backup_storage_class" {
  description = "The storage class you set for an object affects the object's availability and pricing model"
  default     = "STANDARD"
  type        = string
}

variable "backup_schedule" {
  description = "Backup schedule in cron format"
  default     = "0 3 * * *"
  type        = string
}

variable "backup_failed_jobs_history_limit" {
  description = "Set retention for failed jobs history"
  default     = 5
  type        = number
}

variable "backup_successful_jobs_history_limit" {
  description = "Set retention for successful jobs history"
  default     = 3
  type        = number
}

variable "es_name_suffix_length" {
  description = "Length of random generated suffix for ES name"
  default     = 8
  type        = number
}

variable "es_image_creation_timeout" {
  description = "Timeout for creating ES image"
  default     = "10m"
  type        = string
}

variable "enable_health_check_logging" {
  description = "Enable health check logging"
  default     = false
  type        = bool
}

variable "health_check_interval_sec" {
  description = "How often (in seconds) to send a health check. The default value is 5 seconds."
  default     = 5
  type        = number
}

variable "health_check_timeout_sec" {
  description = "How long (in seconds) to wait before claiming failure. The default value is 5 seconds. It is invalid for timeoutSec to have greater value than checkIntervalSec."
  default     = 5
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "How many consecutive successes must occur to mark a VM instance healthy."
  default     = 2
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "How many consecutive failures must occur to mark a VM instance unhealthy."
  default     = 2
  type        = number
}

variable "backend_service_timeout_sec" {
  description = "How many seconds to wait for the backend before considering it a failed request. Default is 30 seconds. Valid range is [1, 86400]."
  default     = 30
  type        = number
}
