locals {
  prefix = var.prefix
}

# VPC
resource "aws_vpc" "this" {
  instance_tenancy = "default"
  cidr_block       = var.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Terraform = "true"
      Name      = var.vpc_name
    }, var.common_tags
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "additional_cidr" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.private_cidr
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Terraform = "true"
      Name      = "${local.prefix}-igw"
    }, var.common_tags
  )
}


# Public Subnets
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Terraform = "true"
      Name      = format("${local.prefix}-public-subnet-%s", var.availability_zones[count.index])
      "kubernetes.io/role/elb"    = "1" # Public load balancer tag
    },
    var.common_tags
  )
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    {
      Terraform = "true"
      Name      = "${local.prefix}-public-rt"
    },
    var.common_tags
  )
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Subnets
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  map_public_ip_on_launch = false
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Terraform = "true"
      Name      = format("${local.prefix}-private-subnet-%s", var.availability_zones[count.index])
      "kubernetes.io/role/internal-elb" = "1" # Internal load balancer tag
    },
    var.common_tags,
  )
}

# Security groups
resource "aws_security_group" "private_subnets" {
  name        = "${local.prefix}-private-subnets-sg"
  description = "Allows private app traffic"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Allow all traffic between private app"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnets_egress
  }

  tags = merge(
    {
      Terraform = "true"
      Name      = "${local.prefix}-private-subnets-sg"
    }, var.common_tags
  )
}

resource "aws_security_group" "public_subnets" {
  name        = "${local.prefix}-eks-lb-sg"
  description = "Security group for EKS ingress load balancers"
  vpc_id      = aws_vpc.this.id

  # Ingress Rules: Allow public HTTP/HTTPS traffic
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress Rules: Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.public_subnets_egress
  }

  tags = merge(
    {
      Terraform = "true"
      Name      = "${local.prefix}-eks-lb-sg"
    },
    var.common_tags
  )
}

# Route table for private subnets with NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  # Route private subnet traffic to NAT Gateway for external access
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[0].id
  }

  tags = merge({
    Name      = "${local.prefix}-private-rt"
    Terraform = "true"
  }, var.common_tags)
}

# Route table association for private subnets
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = element(
    aws_route_table.private.*.id,
    count.index
  )
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc = true

  tags = merge(
    {
      Terraform = "true"
      "Name" = format(
        "${local.prefix}-eip-%s",
        element(var.availability_zones, count.index)
      )
    }, var.common_tags
  )
}

#private_app NAT gateway
resource "aws_nat_gateway" "nat_gw" {
  count = length(var.public_subnets)

  allocation_id = element(
    aws_eip.nat.*.id,
    count.index,
  )

  subnet_id = element(
    aws_subnet.public_subnets.*.id,
    count.index,
  )

  tags = merge(
    {
      Terraform = "true"
      "Name" = format(
        "${local.prefix}-gateway-%s",
        element(var.availability_zones, count.index)
      )
    }, var.common_tags
  )

  depends_on = [aws_internet_gateway.this]
}
