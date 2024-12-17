################################################################################
# Providers
################################################################################

provider "aws" {
  region = var.region
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
  providers = {
    aws = aws
  }

  source = "../../../modules/aws/vpc"

  region             = var.region
  vpc_name           = "${terraform.workspace}-${random_string.this.result}-vpc"
  prefix             = random_string.this.result
  availability_zones = var.availability_zones
  cidr               = var.cidr
  private_subnets    = var.private_subnets
}
