#------------------------------
# Network config
#------------------------------
resource "google_compute_network" "wp" {
  name                    = "wp"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "wp" {
  name          = "wp"
  ip_cidr_range = var.subnet_cidr
  network       = google_compute_network.wp.self_link
  region        = var.region
}

