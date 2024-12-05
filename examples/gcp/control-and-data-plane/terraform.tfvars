# GCP Project
project_id = "my-gcp-project"
region     = "us-west2"
zone       = "us-west2-a"

# VPC
subnets = [
  {
    name               = "private-subnet-a"
    ip_cidr_range      = "10.0.64.0/19"
    region             = "us-west2"
  },
  {
    name               = "private-subnet-b"
    ip_cidr_range      = "10.0.96.0/19"
    region             = "us-west2"
  }
]

private_subnets = ["10.0.64.0/19", "10.0.96.0/19"]


