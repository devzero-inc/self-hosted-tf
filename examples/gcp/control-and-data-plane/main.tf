################################################################################
# Providers
################################################################################

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

################################################################################
# Common resources
################################################################################

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

################################################################################
# VPC
################################################################################

module "vpc" {
  source = "../../../modules/gcp/vpc"

  project_id = var.project_id
  region     = var.region
  vpc_name   = "${terraform.workspace}-${random_string.this.result}-vpc"
  prefix     = random_string.this.result
  subnets    = var.subnets
}

################################################################################
# GKE
################################################################################

module "gke" {
  source = "../../../modules/gcp/gke"

  project_id = var.project_id
  # Cluster Name should not include (-, special char, and numbers)
  cluster_name = var.cluster_name
  region       = var.region
  network      = module.vpc.vpc_name
  subnetwork   = module.vpc.vpc_subnets[0]
  # Define IP Range Pods and Services based on what name you are giving in your VPC module
  ip_range_pods              = "pods-ip-range"
  ip_range_services          = "services-ip-range"
  http_load_balancing        = var.http_load_balancing
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  cluster_auto_upgrade       = var.cluster_auto_upgrade
  gcp_filestore_csi_driver   = var.gcp_filestore_csi_driver
  network_policy             = var.network_policy
  enable_private_endpoint    = var.enable_private_endpoint
  enable_private_nodes       = var.enable_private_nodes
  # Master IPV4 CIDR Must be /28 subnet and should not overlap with any subnet or secondary range.
  master_ipv4_cidr_block      = var.master_ipv4_cidr_block
  cluster_deletion_protection = var.cluster_deletion_protection
  node_pools                  = var.node_pools
  node_pools_oauth_scopes     = var.node_pools_oauth_scopes
  node_pools_labels           = var.node_pools_labels
  node_pools_tags             = var.node_pools_tags

  depends_on = [ module.filestore ]
}

module "filestore" {
  source = "../../../modules/gcp/filestore"

  zone            = var.zone
  project_id      = var.project_id
  vpc_name        = module.vpc.vpc_name
  instance_name   = var.instance_name
  tier            = var.tier
  description     = var.description
  file_share_name = var.file_share_name
  capacity_gb     = var.capacity_gb
  labels          = var.filestore_labels
}