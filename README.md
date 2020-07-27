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
  source            = "github.com/AckeeCZ/terraform-elasticsearch?ref=v5.4.0"
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
| terraform | >= 0.12 |
| kubernetes | ~> 1.11.0 |

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| google-beta | n/a |
| kubernetes | ~> 1.11.0 |
| random | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| add\_random\_suffix | Add random suffix to all resources with possible duplicates if the same modul is deployed multiple times | `bool` | `false` | no |
| allowed\_ipv4\_subnets | IPv4 subnets allowed to communicate with ES instances. | `list(string)` | `[]` | no |
| allowed\_tags | Network tags allowed to communicate with ES instances. | `list(string)` | `[]` | no |
| cluster\_ca\_certificate | Public CA certificate that is the root of trust for the GKE K8s cluster | `string` | n/a | yes |
| cluster\_endpoint | Cluster control plane endpoint | `string` | n/a | yes |
| cluster\_name | ES cluster name. | `string` | n/a | yes |
| cluster\_password | Cluster master password, keep always secret! | `string` | n/a | yes |
| cluster\_user | Cluster master username, keep always secret! | `string` | n/a | yes |
| data\_disk\_size | Persistent disk size specified in GB. | `string` | n/a | yes |
| data\_disk\_type | Type of disk used as a persistent storage. | `string` | `"pd-ssd"` | no |
| heap\_size | Heap size setting for ES. | `string` | `"1800m"` | no |
| instance\_name | Base for GCE instances name. Must be unique within GCP project | `string` | n/a | yes |
| load\_balancer\_subnetwork | The subnetwork that the load balanced IP should belong to for this Forwarding Rule. If the network specified is in auto subnet mode, this field is optional. However, if the network is in custom subnet mode, a subnetwork must be specified. | `string` | `"10.64.0.0/26"` | no |
| namespace | K8s namespace used to deploy endpoints and services. | `string` | `"production"` | no |
| network | GCE VPC used for compute instances | `string` | `"default"` | no |
| node\_count | Number of ES nodes to deploy. | `number` | `1` | no |
| project | Name of GCP project. | `string` | n/a | yes |
| raw\_image\_source | URL of tar archive containing RAW source for ES image (you can use Packer image template to generate image, as mentioned above). | `string` | `"https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"` | no |
| region | Region of GCP project. | `string` | n/a | yes |
| zone | Zone of GCP project - optional parameter, if not set, the instances will be spread across the available zones. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| ilb\_dns | DNS name follows GCP internal rule SERVICE\_LABEL.FORWARDING\_RULE\_NAME.il4.REGION.lb.PROJECT\_ID.internal |
| ip\_address | The internal IP assigned to the regional forwarding rule. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
