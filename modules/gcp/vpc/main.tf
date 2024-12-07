locals {
  prefix = var.prefix
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id

  routing_mode = "GLOBAL"
}

# Subnets
resource "google_compute_subnetwork" "private_subnets" {
  count = length(var.subnets)

  name          = var.subnets[count.index].name
  ip_cidr_range = var.subnets[count.index].ip_cidr_range
  network       = google_compute_network.vpc.id
  region        = var.region
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name    = "fw-${local.prefix}-allow-internal"
  network = google_compute_network.vpc.id

  allow {
    protocol = "all"
    ports    = []
  }

  source_ranges = ["10.0.0.0/8"]

}

module "cloud_nat" {
  source       = "terraform-google-modules/cloud-nat/google"
  project_id   = var.project_id
  region       = var.region

  create_router = true
  router        = "r-${local.prefix}-router"
  network       = google_compute_network.vpc.self_link 

  nat_ips   = []
  
}
