variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "prefix" {
  type        = string
  description = "VPC prefix"
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
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets_egress" {
  description = "Private eggress subnets"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "public_subnets_egress" {
  description = "Public eggress subnets"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "common_tags" {
  description = "Additional common tags"
  type        = map(string)
  default     = {}
}
