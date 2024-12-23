region = "us-west-1"

# EKS
worker_instance_type = "m5.4xlarge"
desired_node_size    = 4
max_node_size        = 4
environment          = "devzero-final"

# VPC
create_vpc = true
availability_zones_count = 3
cidr            = "10.0.0.0/16"
