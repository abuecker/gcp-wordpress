#-----------------------------------
# Cloud SQL - MySQL
#-----------------------------------
resource "random_id" "db" {
  keepers = {
    it = 5
  }

  byte_length = 2
  prefix      = "wp-"
}

#-----------
# Instances
#-----------
resource "google_sql_database_instance" "mysql" {
  name             = "${random_id.db.hex}"
  database_version = "MYSQL_5_7"
  region           = "${var.region}"

  settings {
    tier = "db-g1-small"

    disk_autoresize = true
    disk_type       = "PD_HDD"

    # maintenance_window = {
    #   day          = 7
    #   hour         = 1
    #   update_track = "stable"
    # }

    # backup_configuration = {
    #   enabled    = true
    #   start_time = "3:00"
    # }
  }
}

output "mysql_ip" {
  value = "${google_sql_database_instance.mysql.ip_address.0.ip_address}"
}

output "mysql_name" {
  value = "${google_sql_database_instance.mysql.name}"
}

#----------
# Database
#----------
variable "DB_USER" {}

variable "DB_PASSWORD" {}

resource "google_sql_database" "wp_db" {
  name      = "wordpress"
  instance  = "${google_sql_database_instance.mysql.name}"
  charset   = "utf8"
  collation = "utf8_general_ci"
}

#-------
# Users
#-------
resource "google_sql_user" "users" {
  name     = "${var.DB_USER}"
  instance = "${google_sql_database_instance.mysql.name}"
  host     = ""
  password = "${var.DB_PASSWORD}"
}

#-----
# DNS
#-----
resource "google_dns_record_set" "mysql" {
  name = "mysql.${google_dns_managed_zone.wp.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.wp.name

  rrdatas = [google_sql_database_instance.mysql.ip_address.0.ip_address]
}

#------------------
# Service Accounts
#------------------
resource "google_service_account" "sa_proxy" {
  account_id   = "sa-wp-proxy"
  display_name = "Cloud Proxy Service Account"
}

resource "google_service_account_key" "key_proxy" {
  service_account_id = "${google_service_account.sa_proxy.id}"
}

output "key_proxy" {
  value = google_service_account_key.key_proxy.private_key
}

