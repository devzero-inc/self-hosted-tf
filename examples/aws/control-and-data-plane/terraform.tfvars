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



# Existing VPC
# create_vpc = false
# vpc_id = "vpc-01b10841e8aa7ffe4"
# public_subnet_ids = ["subnet-0e8a32d453c903bc0", "subnet-0078f932dcb7019ef"]
# private_subnet_ids = ["subnet-0d90d150884db0e51", "subnet-022521c7e828f3afa"]
# security_group_ids = ["sg-0c6852476f3a2a571"]
