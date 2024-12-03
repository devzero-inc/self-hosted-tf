# VPC
variable "region" {
  type        = string
  description = "AWS region"
}

variable "environment" {
  type        = string
  description = "Cluster environment"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
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

variable "min_node_size" {
  type        = number
  description = "Min node size"
}

variable "security_group_ids" {
  description = "Security groups"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Subnets"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Additional common tags"
  type        = map(string)
  default     = {}
}

variable "disk_size" {
  description = "Nodes disk size in GiB"
  type = number
  default = 200
}
