# Create a route for machines with no external ip to use the bastion as a NAT
resource "google_compute_route" "nat" {
  name                   = "no-ip-internet-route"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.wp.name
  next_hop_instance      = google_compute_instance.bastion.self_link
  next_hop_instance_zone = var.zone
  priority               = 800
  tags                   = ["no-public-ip"]
}

# use the loadbalancer as nat egress
resource "google_compute_route" "nat-lb" {
  name                   = "no-ip-internet-route-lb"
  dest_range             = "0.0.0.0/0"
  network                = google_compute_network.wp.name
  next_hop_instance      = google_compute_instance.lb.self_link
  next_hop_instance_zone = var.zone
  priority               = 801
  tags                   = ["no-public-ip-lb"]
}

