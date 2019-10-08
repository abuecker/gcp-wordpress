variable "project" {
  default = "gcp-wordpress-255123"
}

variable "region" {
  default = "us-west2"
}

variable "zone" {
  default = "us-west2-b"
}

variable "subnet_cidr" {
  default = "10.239.0.0/20"
}

variable "whitelist" {
  type = list(string)
}

terraform {
  backend "gcs" {
    bucket = "ab-theorem-wordpress"
    prefix = "theorem-wordpress"
  }
}

provider "google" {
  version = "~> 2.5.0"
  project = var.project
  region  = var.region
}

#-----------------------------
# Enable API's for the project
#-----------------------------
resource "google_project_services" "wp" {
  project = var.project
  # disable_on_destroy = true

  services = [
    "bigquery-json.googleapis.com",
    "bigquerystorage.googleapis.com",
    "cloudapis.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "clouddebugger.googleapis.com",
    "cloudtrace.googleapis.com",
    "compute.googleapis.com",
    "datastore.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
  ]
}

# Setup service account IAM policies
resource "google_project_iam_binding" "sa" {
  role = "roles/iam.serviceAccountUser"

  members = [
    "serviceAccount:sa-terraform@gcp-wordpress-255123.iam.gserviceaccount.com",
    "serviceAccount:${google_service_account.sa_bastion.email}",
    "serviceAccount:${google_service_account.sa_wp.email}",
    "serviceAccount:${google_service_account.sa_lb.email}",
    "serviceAccount:${google_service_account.sa_proxy.email}",
  ]
}

# Let bastion service account access other instances
resource "google_project_iam_binding" "compute_admin" {
  role = "roles/compute.admin"

  members = [
    "serviceAccount:${google_service_account.sa_bastion.email}",
  ]
}

resource "google_project_iam_binding" "sql_client" {
  role = "roles/cloudsql.client"

  members = [
    "serviceAccount:${google_service_account.sa_proxy.email}",
  ]
}
