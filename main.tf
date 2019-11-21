resource "google_service_account" "es-backup-sa" {
  account_id   = "es-backup-sa"
  display_name = "es-backup-sa"
  project      = var.project
}

# requires Terraform user to have more privileges than Editor - https://cloud.google.com/resource-manager/docs/access-control-org
resource "google_project_iam_member" "es-backup-role" {
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.es-backup-sa.email}"
  project = var.project
}

resource "google_service_account_key" "es-backup-sa-key" {
  service_account_id = google_service_account.es-backup-sa.name
}

resource "google_compute_image" "elasticsearch-image" {
  name = "elasticsearch-image"

  raw_disk {
    source = var.raw_image_source
  }
  timeouts {
    create = "10m"
  }
}

resource "google_compute_instance" "es_instance" {
  name         = "${var.instance_name}-${count.index}"
  machine_type = "n1-standard-1"
  zone         = var.zone
  count        = var.node_count

  tags = ["es", "elasticsearch"]

  boot_disk {
    initialize_params {
      image = google_compute_image.elasticsearch-image.self_link
      type  = "pd-ssd"
      size  = "30"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    foo      = "bar"
    ssh-keys = "devops:${tls_private_key.provision_key.public_key_openssh}"
  }

  metadata_startup_script = "systemctl enable elasticsearch.service;"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-rw", "monitoring-write", "logging-write", "https://www.googleapis.com/auth/trace.append"]
  }

  provisioner "file" {
    content     = templatefile("${path.module}/elasticsearch.yml.tpl", { project = var.project, zone = var.zone, cluster_name = var.cluster_name })
    destination = "/tmp/elasticsearch.yml"

    connection {
      host        = "${google_compute_instance.es_instance[count.index].network_interface.0.access_config.0.nat_ip}"
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision_key.private_key_pem
      agent       = false
    }
  }

  provisioner "file" {
    content     = templatefile("${path.module}/jvm.options.tpl", { heap_size = var.heap_size })
    destination = "/tmp/jvm.options"

    connection {
      host        = "${google_compute_instance.es_instance[count.index].network_interface.0.access_config.0.nat_ip}"
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision_key.private_key_pem
      agent       = false
    }
  }

  provisioner "file" {
    content     = base64decode(google_service_account_key.es-backup-sa-key.private_key)
    destination = "/tmp/backup-sa.key"

    connection {
      host        = "${google_compute_instance.es_instance[count.index].network_interface.0.access_config.0.nat_ip}"
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision_key.private_key_pem
      agent       = false
    }
  }

  provisioner "remote-exec" {
    connection {
      host        = "${google_compute_instance.es_instance[count.index].network_interface.0.access_config.0.nat_ip}"
      type        = "ssh"
      user        = "devops"
      private_key = tls_private_key.provision_key.private_key_pem
      agent       = false
    }

    inline = [
      "sudo mv /tmp/elasticsearch.yml /etc/elasticsearch",
      "sudo mv /tmp/jvm.options /etc/elasticsearch",
      "sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add-file gcs.client.default.credentials_file /tmp/backup-sa.key",
      "sudo rm /tmp/backup-sa.key",
      "sudo systemctl start elasticsearch.service",
    ]
  }

  //not sure if ok for production
  allow_stopping_for_update = true
}

resource "tls_private_key" "provision_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "google_compute_firewall" "es-allow-cluster" {
  name     = "es-allow-cluster-${var.instance_name}"
  network  = "default"
  priority = "1000"

  allow {
    protocol = "tcp"
    ports    = ["9200", "9300"]
  }
  source_ranges = [var.cluster_ipv4_cidr]
  source_tags   = ["elasticsearch"]
}

