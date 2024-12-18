# VPC
region = "us-west-2"
availability_zones = ["us-west-2a", "us-west-2b"]
cidr               = "10.0.0.0/16"
private_cidr       = "100.128.0.0/16"
public_subnets     = ["10.0.0.0/19", "10.0.32.0/19"] 
private_subnets    = ["100.128.0.0/19", "100.128.32.0/19"]
