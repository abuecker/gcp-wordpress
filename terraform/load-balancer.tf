#------------------
# Service Accounts
#------------------
resource "google_service_account" "sa_lb" {
  account_id   = "vcs-lb"
  display_name = "VCS Load Balancer Service Account"
}

#------------------
# Compute Instance
#------------------
resource "google_compute_instance" "lb" {
  name                      = "lb"
  machine_type              = "g1-small"
  zone                      = var.zone
  allow_stopping_for_update = true
  can_ip_forward            = true

  tags = [
    "lb",
    "nat-internal"
  ]

  boot_disk {
    initialize_params {
      image = "lb-1570493804"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.wp.name

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    email = google_service_account.sa_lb.email

    scopes = [
      "compute-ro",
    ]
  }
}

resource "google_dns_record_set" "lb" {
  name = "lb.${google_dns_managed_zone.wp.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.wp.name

  rrdatas = [google_compute_instance.lb.network_interface.0.network_ip]
}

resource "google_dns_record_set" "lb-public" {
  name = google_dns_managed_zone.wp.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.wp.name

  rrdatas = [google_compute_instance.lb.network_interface.0.access_config.0.nat_ip]
}
