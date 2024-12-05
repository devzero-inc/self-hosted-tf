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

  project_id       = var.project_id
  region           = var.region
  vpc_name         = "${terraform.workspace}-${random_string.this.result}-vpc"
  prefix           = random_string.this.result
  subnets          = var.subnets
}
