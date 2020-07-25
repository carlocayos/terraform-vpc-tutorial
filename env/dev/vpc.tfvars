aws_region     = "ap-southeast-2"
vpc_cidr_block = "10.0.0.0/16"

az_public_subnet   = { "ap-southeast-2a" : "10.0.0.0/24", "ap-southeast-2b" : "10.0.1.0/24", "ap-southeast-2c" : "10.0.2.0/24" }
az_private_subnet  = { "ap-southeast-2a" : "10.0.101.0/24", "ap-southeast-2b" : "10.0.102.0/24", "ap-southeast-2c" : "10.0.103.0/24" }
az_database_subnet = { "ap-southeast-2a" : "10.0.201.0/24", "ap-southeast-2b" : "10.0.202.0/24", "ap-southeast-2c" : "10.0.203.0/24" }

ec2_instance_az = "ap-southeast-2a"