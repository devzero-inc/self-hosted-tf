# GCP Project
variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "zone" {
  type        = string
  description = "GCP zone"
}

# VPC
variable "subnets" {
  description = "Subnets configuration"
  type = list(object({
    name               = string
    ip_cidr_range      = string
    region             = string
  }))
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

