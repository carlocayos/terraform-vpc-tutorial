variable "aws_region" {
  description = "AWS Region"
}
variable "vpc_cidr_block" {
  description = "Main VPC CIDR Block"
}

#-------------------------------
# Variables
# https://www.terraform.io/docs/configuration/variables.html
#-------------------------------
variable "az_public_subnet" {
  type = map(string)
}

variable "az_private_subnet" {
  type = map(string)
}

variable "az_database_subnet" {
  type = map(string)
}

variable "ec2_instance_az" {
  type = string
}