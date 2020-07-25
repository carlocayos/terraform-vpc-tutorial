#-------------------------------
# AWS Provider
#-------------------------------
provider "aws" {
  region = var.aws_region
}

#-------------------------------
# S3 Remote State
#-------------------------------
terraform {
  backend "s3" {
    bucket = "my-terraform-bucket-12345"
    key    = "vpc.tfstate"
    region = "ap-southeast-2"
  }
}

#-------------------------------
# VPC resource
#-------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name        = "my-terraform-aws-vpc-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

#-------------------------------
# Internet Gateway
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
#-------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-internet-gateway-${terraform.workspace}"
  }
}

#-------------------------------
# Subnet
# https://www.terraform.io/docs/providers/aws/r/subnet.html
# https://www.terraform.io/docs/configuration/resources.html#for_each-multiple-resource-instances-defined-by-a-map-or-set-of-strings
#-------------------------------
# Public Subnet
resource "aws_subnet" "public_subnet" {
  for_each = var.az_public_subnet

  vpc_id = aws_vpc.main.id

  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "my-public-subnet-${each.key}-${terraform.workspace}"
    Tier = "public"
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  for_each = var.az_private_subnet

  vpc_id = aws_vpc.main.id

  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "my-private-subnet-${each.key}-${terraform.workspace}"
    Tier = "private"
  }
}

# Database Subnet
resource "aws_subnet" "database_subnet" {
  for_each = var.az_database_subnet

  vpc_id = aws_vpc.main.id

  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name = "my-database-subnet-${each.key}-${terraform.workspace}"
    Tier = "database"
  }
}


#-------------------------------
# Route Table
# https://www.terraform.io/docs/providers/aws/r/route_table.html
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
#-------------------------------

# public subnet route table
resource "aws_route_table" "public_subnet_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-public-subnet-route-table"
  }
}

# public subnet route table association
resource "aws_route_table_association" "public_subnet_route_table_association" {
  for_each = var.az_public_subnet

  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.public_subnet_route_table.id
}

#-------------------------------
# NAT Gateway
#-------------------------------
# EIP
resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
}

# NAT Gateway
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[var.ec2_instance_az].id
}

#-------------------------------
# Route Table to private subnet
#-------------------------------
resource "aws_route_table" "private_subnet_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "my-private-subnet-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  for_each = var.az_private_subnet

  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.private_subnet_route_table.id
}

#-------------------------------
# Route Table to database subnet
#-------------------------------
resource "aws_route_table" "database_subnet_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw.id
  }

  tags = {
    Name = "my-database-subnet-route-table"
  }
}

resource "aws_route_table_association" "database_subnet_route_table_association" {
  for_each = var.az_database_subnet

  subnet_id      = aws_subnet.database_subnet[each.key].id
  route_table_id = aws_route_table.database_subnet_route_table.id
}