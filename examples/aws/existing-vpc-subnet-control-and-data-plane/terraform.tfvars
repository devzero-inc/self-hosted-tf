region = "us-west-2"

# EKS
worker_instance_type = "m5.4xlarge"
desired_node_size    = 4
max_node_size        = 4
environment          = "devzero-final"

# VPC
vpc_private_subnets    = ["subnet-04f7a638886889206", "subnet-0010bc7d01d9959a9"]
vpc_public_subnets     = ["subnet-0b601ab1718e03b31", "subnet-0954665d713db00f1"]
vpc_availability_zones = ["us-west-2a", "us-west-2b"]
vpc_id                 = "vpc-00e8585335207de88"
