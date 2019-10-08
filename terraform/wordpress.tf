#------------------
# Service Accounts
#------------------
resource "google_service_account" "sa_wp" {
  account_id   = "sa-wpress"
  display_name = "Wordpress Service Account"
}


# Instances
resource "google_compute_instance" "wp" {
  name                      = "wp"
  machine_type              = "g1-small"
  zone                      = var.zone
  tags                      = ["wordpress", "no-public-ip-lb"]
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "wordpress-1570540944"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.wp.name
  }

  service_account {
    email = google_service_account.sa_wp.email

    scopes = [
      "compute-ro",
    ]
  }

  metadata_startup_script = <<EOF
echo '${google_service_account_key.key_proxy.private_key}' | base64 --decode > /etc/wp/creds-cloud-sql.json
echo "PROXY_CONNECTION=${google_sql_database_instance.mysql.connection_name}" > /etc/wp/cloud_sql_env
EOF
}

#-----
# DNS
#-----
resource "google_dns_record_set" "wp" {
  name = "wp.${google_dns_managed_zone.wp.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.wp.name

  rrdatas = [google_compute_instance.wp.network_interface.0.network_ip]
}
