data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

resource "random_string" "es_name_suffix" {
  length  = 8
  special = false
  upper   = false
  count   = var.add_random_suffix ? 1 : 0
}

locals {
  zone_count = length(data.google_compute_zones.available.names)
  elasticsearch_configuration = templatefile(
    "${path.module}/elasticsearch.yml.tpl",
    {
      project      = var.project,
      zones        = join(", ", data.google_compute_zones.available.names),
      cluster_name = var.cluster_name
    }
  )
  elasticsearch_fluentd = templatefile(
    "${path.module}/fluentd.conf.tpl",
    {
      cluster_name = var.cluster_name
    }
  )
  master_list = join(",",
    [
      for i in range(var.node_count) :
      "${var.instance_name}-${i}${local.suffix}"
    ]
  )
  suffix            = var.add_random_suffix ? "-${random_string.es_name_suffix[0].result}" : ""
  backup_repository = var.backup_repository_name == "" ? "${var.project}-elasticsearch-backups${local.suffix}" : var.backup_repository_name
}

resource "google_service_account" "elasticsearch_backup" {
  account_id   = "elasticsearch-backup${local.suffix}"
  display_name = "elasticsearch-backup"
  project      = var.project
}

# requires Terraform user to have more privileges than Editor - https://cloud.google.com/resource-manager/docs/access-control-org
resource "google_project_iam_member" "elasticsearch_backup_role" {
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.elasticsearch_backup.email}"
  project = var.project
}

resource "google_service_account_key" "elasticsearch_backup" {
  service_account_id = google_service_account.elasticsearch_backup.name
}

resource "google_compute_image" "elasticsearch" {
  name = "elasticsearch-image${local.suffix}"

  raw_disk {
    source = var.raw_image_source
  }
  timeouts {
    create = "10m"
  }
}

resource "google_compute_disk" "data" {
  name  = "${var.instance_name}-${count.index}-persistent-data${local.suffix}"
  type  = var.data_disk_type
  size  = var.data_disk_size
  zone  = var.zone != null ? var.zone : data.google_compute_zones.available.names[count.index % local.zone_count]
  count = var.node_count
}

resource "google_compute_instance" "elasticsearch" {
  name         = "${var.instance_name}-${count.index}${local.suffix}"
  machine_type = var.machine_type
  zone         = var.zone != null ? var.zone : data.google_compute_zones.available.names[count.index % local.zone_count]
  count        = var.node_count

  tags = ["es", "elasticsearch"]

  boot_disk {
    initialize_params {
      image = google_compute_image.elasticsearch.self_link
      type  = "pd-ssd"
      size  = var.root_disk_size
    }
  }
  attached_disk {
    source      = google_compute_disk.data[count.index].name
    device_name = "elasticpd"
  }

  network_interface {
    network = var.network
  }

  metadata = {
    ssh-keys  = "devops:${tls_private_key.provision.public_key_openssh}"
    user-data = <<-EOT
#!/bin/bash

export MASTER_LIST=${local.master_list}
export BACKUP_REPOSITORY=${local.backup_repository}

base64 -d <<< "${base64encode(local.elasticsearch_configuration)}" > /tmp/elasticsearch.yml
base64 -d <<< "${base64encode(local.elasticsearch_fluentd)}" > /etc/google-fluentd/config.d/${var.cluster_name}.conf
base64 -d <<< "${google_service_account_key.elasticsearch_backup.private_key}" > /tmp/backup-sa.key
base64 -d <<< "${filebase64("${path.module}/bootstrap.sh")}" > /tmp/bootstrap.sh

mv /tmp/elasticsearch.yml /etc/elasticsearch
sed -i 's/^\\(-Xm[xs]\\).*/\\1${var.heap_size}/' /etc/elasticsearch/jvm.options
/usr/share/elasticsearch/bin/elasticsearch-keystore add-file gcs.client.default.credentials_file /tmp/backup-sa.key
rm /tmp/backup-sa.key
bash /tmp/bootstrap.sh

systemctl restart google-fluentd.service
systemctl start elasticsearch.service

${var.custom_init_commands}

  EOT
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-rw", "monitoring-write", "logging-write", "https://www.googleapis.com/auth/trace.append"]
  }

  # not sure if ok for production
  allow_stopping_for_update = true
}

resource "tls_private_key" "provision" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
