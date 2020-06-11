data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
}

locals {
  zone_count = length(data.google_compute_zones.available.names)
}

resource "google_service_account" "elasticsearch_backup" {
  account_id   = "elasticsearch-backup"
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
  name = "elasticsearch-image"

  raw_disk {
    source = var.raw_image_source
  }
  timeouts {
    create = "10m"
  }
}

resource "google_compute_disk" "data" {
  name  = "${var.instance_name}-${count.index}-persistent-data"
  type  = var.data_disk_type
  size  = var.data_disk_size
  zone  = var.zone != null ? var.zone : data.google_compute_zones.available.names[count.index % local.zone_count]
  count = var.node_count
}

resource "google_compute_instance" "elasticsearch" {
  name         = "${var.instance_name}-${count.index}"
  machine_type = "n1-standard-1"
  zone         = var.zone != null ? var.zone : data.google_compute_zones.available.names[count.index % local.zone_count]
  count        = var.node_count

  tags = ["es", "elasticsearch"]

  boot_disk {
    initialize_params {
      image = google_compute_image.elasticsearch.self_link
      type  = "pd-ssd"
      size  = "10"
    }
  }
  attached_disk {
    source      = "${var.instance_name}-${count.index}-persistent-data"
    device_name = "elasticpd"
  }

  network_interface {
    network = var.network

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "devops:${tls_private_key.provision.public_key_openssh}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-rw", "monitoring-write", "logging-write", "https://www.googleapis.com/auth/trace.append"]
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/elasticsearch.yml.tpl", {
        project      = var.project,
        zones        = join(", ", data.google_compute_zones.available.names),
        cluster_name = var.cluster_name
      }
    )
    destination = "/tmp/elasticsearch.yml"

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision.private_key_pem
      agent       = false
    }
  }

  provisioner "file" {
    content     = base64decode(google_service_account_key.elasticsearch_backup.private_key)
    destination = "/tmp/backup-sa.key"

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision.private_key_pem
      agent       = false
    }
  }

  provisioner "file" {
    content = templatefile(
      "${path.module}/master_list.sh.tpl", {
        master_list = join(",", [
          for i in range(var.node_count) :
          "${var.instance_name}-${i}"
        ])
      }
    )
    destination = "/home/devops/master_list.sh"

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision.private_key_pem
      agent       = false
    }
  }

  provisioner "file" {
    source      = "${path.module}/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision.private_key_pem
      agent       = false
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision.private_key_pem
      agent       = false
    }

    inline = [
      "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch",
      "sudo sed -i 's/^\\(-Xm[xs]\\).*/\\1${var.heap_size}/' /etc/elasticsearch/jvm.options",
      "sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add-file gcs.client.default.credentials_file /tmp/backup-sa.key",
      "sudo rm /tmp/backup-sa.key",
      "sudo bash /tmp/bootstrap.sh",
      "sudo systemctl start elasticsearch.service"
    ]
  }

  # not sure if ok for production
  allow_stopping_for_update = true
}

resource "tls_private_key" "provision" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
