# Ackee GCE Elasticsearch Terraform module

This module is primary written for provisioning of GCE instance from our ES image (https://github.com/AckeeCZ/packer-elasticsearch)

It does a few things :
* Generates GCP IAM Service Account with Storage Admin role for backups and insert it into ES keystore
* Downloads RAW disk from GCS and create an image from it. (you can generate your own image with Packer using https://github.com/AckeeCZ/packer-elasticsearch)
* Create SSH key for instance provisioning
* Create (GCP) firewall rules so GKE "gateway" pods can reach GCE cluster

## Configuration

https://github.com/AckeeCZ/terraform-elasticsearch/blob/master/variables.tf explanation  (followed by default values if applicable) :

* project - name of GCP project
* zone - zone of GCP project
* instance_name - base for GCE instances name
* cluster_ipv4_cidr - IPv4 CIDR of k8s cluster, that will communicate
* node_count:1 - number of ES nodes to deploy
* heap_size:2g - heap size setting for ES
* cluster_name - ES cluster name
* raw_image_source -  URL of tar archive containing RAW source for ES image (you can use Packer image template to generate image, as mentioned above)


## Usage

```hcl
module "es-prod" {
  source = "github.com/AckeeCZ/terraform-elasticsearch?ref=v1.0.0"
  project = "my-gcp-project"
  zone = "europe-west3-c"
  instance_name = "redis-prod"
  cluster_ipv4_cidr = "10.123.0.0/14"
  count = "3"
  heap_size = "1500m"
  raw_image_source = "https://storage.googleapis.com/image-bucket/ackee-es6.4-disk-latest.tar.gz"
}

```
