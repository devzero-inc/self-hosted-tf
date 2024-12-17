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
variable "vpc_private_subnets" {
  description = "Private subnets to be used for the EKS cluster"
  type        = list(string)
}

variable "vpc_availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "private_subnets_egress" {
  description = "Private eggress subnets"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "vpc_id" {
  description = "The existing VPC ID"
  type        = string
}

