region = "us-west-2"

# EKS
worker_instance_type = "m5.4xlarge"
desired_node_size    = 4
max_node_size        = 4
environment          = "devzero-final"

# VPC
availability_zones = ["us-west-2a", "us-west-2b"]
cidr               = "10.0.0.0/16"
private_subnets    = ["10.0.64.0/19", "10.0.96.0/19"]

