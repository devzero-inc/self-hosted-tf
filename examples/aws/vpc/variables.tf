# VPC

variable "region" {
  type        = string
  description = "AWS region"
}

variable "cidr" {
  type        = string
  description = "Cidr block"
}

variable "private_cidr" {
  type        = string
  description = "Private Cidr block"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets"
  type        = list(string)
}
