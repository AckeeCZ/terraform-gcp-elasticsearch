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
| google | ~> 3.19.0 |
| kubernetes | ~> 1.11.0 |

## Providers

| Name | Version |
|------|---------|
| google | ~> 3.19.0 |
| kubernetes | ~> 1.11.0 |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_ca\_certificate | Public CA certificate that is the root of trust for the GKE K8s cluster | `string` | n/a | yes |
| cluster\_endpoint | Cluster control plane endpoint | `string` | n/a | yes |
| cluster\_ipv4\_cidr | IPv4 CIDR of k8s cluster used for ES communication. | `any` | n/a | yes |
| cluster\_name | ES cluster name. | `string` | n/a | yes |
| cluster\_password | Cluster master password, keep always secret! | `string` | n/a | yes |
| cluster\_user | Cluster master username, keep always secret! | `string` | n/a | yes |
| data\_disk\_size | Persistent disk size specified in GB. | `any` | n/a | yes |
| data\_disk\_type | Type of disk used as a persistent storage. | `string` | `"pd-ssd"` | no |
| heap\_size | Heap size setting for ES. | `string` | `"1800m"` | no |
| instance\_name | Base for GCE instances name. | `any` | n/a | yes |
| k8s\_enable | Enable k8s extension to deploy endpoints to cluster members and internal load balancer as a k8s service, use only with k8s provider setup previously | `bool` | `false` | no |
| namespace | K8s namespace used to deploy endpoints and services. | `string` | `"production"` | no |
| node\_count | Number of ES nodes to deploy. | `string` | `"1"` | no |
| project | Name of GCP project. | `string` | n/a | yes |
| raw\_image\_source | URL of tar archive containing RAW source for ES image (you can use Packer image template to generate image, as mentioned above). | `string` | `"https://storage.googleapis.com/ackee-images/ackee-elasticsearch-7-disk-79.tar.gz"` | no |
| region | Region of GCP project. | `string` | n/a | yes |
| zone | Zone of GCP project - optional parameter, if not set, the instances will be spread across the available zones. | `any` | `null` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
