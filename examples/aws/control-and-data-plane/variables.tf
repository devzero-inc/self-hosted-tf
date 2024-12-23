#EKS
variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Cluster environment"
}

variable "worker_instance_type" {
  type        = string
  description = "Node instance type"
}

variable "desired_node_size" {
  type        = number
  description = "Desired node size"
}

variable "max_node_size" {
  type        = number
  description = "Max node size"
}

variable "subnet_ids" {
  description = "Subnets"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "security groups ids"
  type        = list(string)
  default     = []
}

# VPC
variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
}

variable "cidr" {
  type        = string
  description = "Cidr block"
}

variable "availability_zones_count" {
  description = "The number of availability zones available for the VPC and EKS cluster"
  type        = number
  default     = 0
}

variable "availability_zones" {
  description = "Availability zones. Required if availability_zones_count is not set"
  type        = list(string)
  default     = []
}

variable "public_subnets" {
  description = "Public subnets. Optionally create public subnets"
  type        = list(string)
  default = []
}

variable "private_subnets" {
  description = "Private subnets. Required if create_vpc is false"
  type        = list(string)
  default = []
}

