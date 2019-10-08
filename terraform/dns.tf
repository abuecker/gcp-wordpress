resource "google_dns_managed_zone" "wp" {
  name        = "theorem"
  dns_name    = "theorem.48s.io."
  description = "Theorem DNS zone"
}

output "name_servers" {
  value = google_dns_managed_zone.wp.name_servers
}

