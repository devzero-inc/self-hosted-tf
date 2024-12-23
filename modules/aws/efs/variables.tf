variable "efs_enabled" {
  default = true
}

variable "efs_pv_name" {
  type = string
}

variable "efs_sc_name" {
  type = string
}

variable "efs_claim_name" {
  type = string
}

variable "efs_controller_sa_name" {
  type = string
}

variable "efs_driver_name" {
  type = string
}

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_version" {
  default = "1.20"
}

variable "enable_ipv6" {
  default = false
}

variable "enable_nat" {
  default = true
}

variable "enable_egress_only_internet_gateway" {
  default = false
}

variable "zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "eips" {
  default = []
}

variable "ec2_keypair" {
  default = "opszero"
}

variable "node_role_policies" {
  default = []
}

variable "fargate_selector" {
  default = {
    serverless = {
      // role_arn =
    },
  }
}

variable "cluster_endpoint" {

}

variable "cluster_ca_certificate" {

}

variable "aws_eks_cluster_auth_token" {

}

variable "provider_url" {

}

variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "security_group_ids" {
  description = "Security groups"
  type        = list(string)
}

variable "app_subnet_id_01" {
  description = "Subnets"
  type        = string
}

variable "app_subnet_id_02" {
  description = "Subnets"
  type        = string
}

variable "common_tags" {
  description = "Additional common tags"
  type        = map(string)
  default     = {}
}
