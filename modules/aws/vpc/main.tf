locals {
  prefix = var.prefix
}

# VPC
resource "aws_vpc" "this" {
  instance_tenancy = "default"
  cidr_block       = var.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Terraform = "true"
      Name      = var.vpc_name
    }, var.common_tags
  )
}

# Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = aws_vpc.this.id

  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Terraform = "true"
      Name = format(
        "${local.prefix}-private-subnet-%s",
        var.availability_zones[count.index],
      )
    }, var.common_tags
  )
}

# Security groups
resource "aws_security_group" "private_subnets" {
  name        = "${local.prefix}-private-subnets-sg"
  description = "Allows private app traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow all traffic between private app"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets_egress
  }

  tags = merge(
    {
      Terraform = "true"
      Name      = "${local.prefix}-private-subnets-sg"
    }, var.common_tags
  )
}