# Ackee GCE Elasticsearch Terraform module

This module is primary written for provisioning of GCE instance from our ES image (https://github.com/AckeeCZ/packer-elasticsearch)

It does a few things :
* Generates GCP IAM Service Account with Storage Admin role for backups and insert it into ES keystore
* Downloads RAW disk from GCS and create an image from it. (you can generate your own image with Packer using https://github.com/AckeeCZ/packer-elasticsearch)
* Create SSH key for instance provisioning
* Create (GCP) firewall rules so GKE "gateway" pods can reach GCE cluster

## Usage

```hcl
module "elasticsearch_prod" {
  source = "AckeeCZ/elasticsearch/gcp"

  project           = "my-gcp-project"
  region            = "europe-west3"
  zone              = "europe-west3-c"
  instance_name     = "elasticsearch-prod"
  cluster_name      = "elasticsearch"
  cluster_ipv4_cidr = "10.128.0.0/14"
  node_count        = "3"
  heap_size         = "1500m"
  raw_image_source  = "https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"
  data_disk_size    = "10"
}
```

## Before you do anything in this module

Install pre-commit hooks by running following commands:

```shell script
brew install pre-commit
pre-commit install
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_forwarding_rule.elasticsearch](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_forwarding_rule) | resource |
| [google-beta_google_compute_health_check.elasticsearch](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_health_check) | resource |
| [google-beta_google_compute_instance_group.elasticsearch](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_instance_group) | resource |
| [google-beta_google_compute_region_backend_service.elasticsearch](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_region_backend_service) | resource |
| [google-beta_google_compute_subnetwork.proxy](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_subnetwork) | resource |
| [google_compute_disk.data](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_firewall.elasticsearch_allow_external_subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.elasticsearch_allow_external_tags](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.elasticsearch_allow_healthchecks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.elasticsearch_allow_ilb_traffic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_image.elasticsearch](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_image) | resource |
| [google_compute_instance.elasticsearch](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_project_iam_member.elasticsearch_backup_role](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.elasticsearch_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.elasticsearch_backup](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.backup_repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [kubernetes_cron_job.backup_cleanup](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cron_job) | resource |
| [kubernetes_stateful_set.elasticsearch](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |
| [random_string.es_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tls_private_key.provision](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_compute_network.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_random_suffix"></a> [add\_random\_suffix](#input\_add\_random\_suffix) | Add random suffix to all resources with possible duplicates if the same module is deployed multiple times | `bool` | `false` | no |
| <a name="input_allowed_ipv4_subnets"></a> [allowed\_ipv4\_subnets](#input\_allowed\_ipv4\_subnets) | IPv4 subnets allowed to communicate with ES instances. | `list(string)` | `[]` | no |
| <a name="input_allowed_tags"></a> [allowed\_tags](#input\_allowed\_tags) | Network tags allowed to communicate with ES instances. | `list(string)` | `[]` | no |
| <a name="input_backup_failed_jobs_history_limit"></a> [backup\_failed\_jobs\_history\_limit](#input\_backup\_failed\_jobs\_history\_limit) | Set retention for failed jobs history | `number` | `5` | no |
| <a name="input_backup_repository_create"></a> [backup\_repository\_create](#input\_backup\_repository\_create) | If GCS bucket should be created. Set to false, if you previously created bucket | `bool` | `true` | no |
| <a name="input_backup_repository_name"></a> [backup\_repository\_name](#input\_backup\_repository\_name) | Custom name of Elasticsearch backup repository, same name is going to be used for backup bucket | `string` | `""` | no |
| <a name="input_backup_schedule"></a> [backup\_schedule](#input\_backup\_schedule) | Backup schedule in cron format | `string` | `"0 3 * * *"` | no |
| <a name="input_backup_storage_class"></a> [backup\_storage\_class](#input\_backup\_storage\_class) | The storage class you set for an object affects the object's availability and pricing model | `string` | `"STANDARD"` | no |
| <a name="input_backup_successful_jobs_history_limit"></a> [backup\_successful\_jobs\_history\_limit](#input\_backup\_successful\_jobs\_history\_limit) | Set retention for successful jobs history | `number` | `3` | no |
| <a name="input_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#input\_cluster\_ca\_certificate) | Public CA certificate that is the root of trust for the GKE K8s cluster | `string` | n/a | yes |
| <a name="input_cluster_endpoint"></a> [cluster\_endpoint](#input\_cluster\_endpoint) | Cluster control plane endpoint | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ES cluster name. | `string` | n/a | yes |
| <a name="input_cluster_token"></a> [cluster\_token](#input\_cluster\_token) | Cluster master token, keep always secret! | `string` | n/a | yes |
| <a name="input_custom_init_commands"></a> [custom\_init\_commands](#input\_custom\_init\_commands) | Any custom commands which should be run after bootstrapping the Elasticsearch cluster | `string` | `""` | no |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | Persistent disk size specified in GB. | `string` | n/a | yes |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | Type of disk used as a persistent storage. | `string` | `"pd-ssd"` | no |
| <a name="input_enable_health_check_logging"></a> [enable\_health\_check\_logging](#input\_enable\_health\_check\_logging) | Enable health check logging | `bool` | `false` | no |
| <a name="input_es_image_creation_timeout"></a> [es\_image\_creation\_timeout](#input\_es\_image\_creation\_timeout) | Timeout for creating ES image | `string` | `"10m"` | no |
| <a name="input_es_name_suffix_length"></a> [es\_name\_suffix\_length](#input\_es\_name\_suffix\_length) | Length of random generated suffix for ES name | `number` | `8` | no |
| <a name="input_heap_size"></a> [heap\_size](#input\_heap\_size) | Heap size setting for ES. | `string` | `"1800m"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Base for GCE instances name. Must be unique within GCP project | `string` | n/a | yes |
| <a name="input_load_balancer_subnetwork"></a> [load\_balancer\_subnetwork](#input\_load\_balancer\_subnetwork) | The subnetwork that the load balanced IP should belong to for this Forwarding Rule. If the network specified is in auto subnet mode, this field is optional. However, if the network is in custom subnet mode, a subnetwork must be specified. | `string` | `"10.64.0.0/26"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to create | `string` | `"n1-standard-1"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | K8s namespace used to deploy endpoints and services. | `string` | `"production"` | no |
| <a name="input_network"></a> [network](#input\_network) | GCE VPC used for compute instances | `string` | `"default"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of ES nodes to deploy. | `number` | `1` | no |
| <a name="input_project"></a> [project](#input\_project) | Name of GCP project. | `string` | n/a | yes |
| <a name="input_raw_image_source"></a> [raw\_image\_source](#input\_raw\_image\_source) | URL of tar archive containing RAW source for ES image (you can use Packer image template to generate image, as mentioned above). | `string` | `"https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region of GCP project. | `string` | n/a | yes |
| <a name="input_root_disk_size"></a> [root\_disk\_size](#input\_root\_disk\_size) | Persistent disk size specified in GB. | `string` | `"10"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Zone of GCP project - optional parameter, if not set, the instances will be spread across the available zones. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ilb_dns"></a> [ilb\_dns](#output\_ilb\_dns) | DNS name follows GCP internal rule SERVICE\_LABEL.FORWARDING\_RULE\_NAME.il4.REGION.lb.PROJECT\_ID.internal |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The internal IP assigned to the regional forwarding rule. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
