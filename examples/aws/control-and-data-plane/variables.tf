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
variable "cidr" {
  type        = string
  description = "Cidr block"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}


variable "private_subnets" {
  description = "Private subnets"
  type        = list(string)
}

