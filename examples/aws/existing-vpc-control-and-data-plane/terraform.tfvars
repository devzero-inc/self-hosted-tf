region = "us-west-2"

# EKS
worker_instance_type = "m5.4xlarge"
desired_node_size    = 4
max_node_size        = 4
environment          = "devzero-final"

# VPC
vpc_private_subnets    = ["10.0.64.0/19", "10.0.96.0/19"]
vpc_availability_zones = ["us-west-2a", "us-west-2b"]
vpc_id                 = "vpc-0357d2217f482d5cc"
