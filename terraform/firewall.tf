#-----------
# Firewall
#-----------
resource "google_compute_firewall" "wp_bastion" {
  name    = "bastion"
  network = google_compute_network.wp.name

  target_tags = [
    "bastion",
    "packer",
  ]

  source_ranges = var.whitelist

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Add a firewall rule so internal nat'd instances can use this node
resource "google_compute_firewall" "nat" {
  name    = "nat-internal"
  network = google_compute_network.wp.name

  target_tags = [
    "nat-internal",
  ]

  source_ranges = [
    var.subnet_cidr,
  ]

  allow {
    protocol = "all"
  }
}

resource "google_compute_firewall" "lb_http" {
  name     = "lb"
  network  = google_compute_network.wp.name
  priority = 900

  source_ranges = [
    "0.0.0.0/0"
  ]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  target_tags = [
    "lb",
  ]
}

resource "google_compute_firewall" "wordpress" {
  name    = "wordpress"
  network = "${google_compute_network.wp.self_link}"

  source_ranges = [
    "${var.subnet_cidr}",
  ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  target_tags = [
    "wordpress",
  ]
}

