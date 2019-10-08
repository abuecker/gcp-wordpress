
# Service Account for the Bastion Instance
resource "google_service_account" "sa_bastion" {
  account_id   = "bastion"
  display_name = "Bastion Service Account"
}

# The bastion instance
resource "google_compute_instance" "bastion" {
  name                      = "bastion"
  machine_type              = "f1-micro"
  zone                      = var.zone
  can_ip_forward            = true # allows this instance to function as a NAT
  tags                      = ["bastion", "nat"]
  allow_stopping_for_update = true

  service_account {
    email = google_service_account.sa_bastion.email

    scopes = [
      "compute-rw",
    ]
  }

  boot_disk {
    initialize_params {
      image = "bastion-1570481146"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.wp.name

    access_config {
      // Ephemeral IP
    }
  }
}

# DNS Record
resource "google_dns_record_set" "bastion" {
  name = "bastion.${google_dns_managed_zone.wp.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.wp.name

  rrdatas = [google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip]
}
