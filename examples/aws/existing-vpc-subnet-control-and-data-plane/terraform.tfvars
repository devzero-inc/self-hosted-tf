region = "us-west-2"

# EKS
worker_instance_type = "m5.4xlarge"
desired_node_size    = 4
max_node_size        = 4
environment          = "devzero-final"

# VPC
vpc_private_subnets    = ["subnet-0f41f815bcb821005", "subnet-0d01b20f7de67cbad"]
vpc_availability_zones = ["us-west-2a", "us-west-2b"]
vpc_id                 = "vpc-0a0ca07beae2d8ed5"
