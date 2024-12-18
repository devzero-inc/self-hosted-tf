output "region" {
  description = "AWS region"
  value       = var.region
}

# VPC
output "vpc_id" {
  description = "The ID of the VPC"
  value       = concat(aws_vpc.this.*.id, [""])[0]
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = concat(aws_vpc.this.*.arn, [""])[0]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = concat(aws_vpc.this.*.cidr_block, [""])[0]
}

output "default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = concat(aws_vpc.this.*.default_security_group_id, [""])[0]
}

output "default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = concat(aws_vpc.this.*.default_network_acl_id, [""])[0]
}

output "default_route_table_id" {
  description = "The ID of the default route table"
  value       = concat(aws_vpc.this.*.default_route_table_id, [""])[0]
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = concat(aws_vpc.this.*.instance_tenancy, [""])[0]
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = concat(aws_vpc.this.*.enable_dns_support, [""])[0]
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = concat(aws_vpc.this.*.enable_dns_hostnames, [""])[0]
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = concat(aws_vpc.this.*.main_route_table_id, [""])[0]
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnets.*.id
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = aws_subnet.private_subnets.*.arn
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private_subnets.*.cidr_block
}

output "private_security_group" {
  description = "List of IDs of private security groups"
  value       = aws_security_group.private_subnets.id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnets.*.id
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.public_subnets.*.arn
}

output "public_subnets_cidr_blocks" {
  description = "List of CIDR blocks of public subnets"
  value       = aws_subnet.public_subnets.*.cidr_block
}

output "public_security_group_id" {
  description = "The ID of the security group for public subnets"
  value       = aws_security_group.public_subnets.id
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = aws_nat_gateway.nat_gw.*.id
}

output "nat_gateway_eips" {
  description = "List of Elastic IPs associated with NAT Gateways"
  value       = aws_eip.nat.*.public_ip
}

output "public_route_table_id" {
  description = "The ID of the route table for public subnets"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the route table for private subnets"
  value       = aws_route_table.private.id
}

output "availability_zones" {
  description = "The availability zones used in this VPC"
  value       = var.availability_zones
}
