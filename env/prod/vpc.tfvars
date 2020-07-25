aws_region     = "ap-northeast-1"
vpc_cidr_block = "10.0.0.0/16"

az_public_subnet   = { "ap-northeast-1a" : "10.0.0.0/24", "ap-northeast-1c" : "10.0.1.0/24" }
az_private_subnet  = { "ap-northeast-1a" : "10.0.101.0/24", "ap-northeast-1c" : "10.0.102.0/24" }
az_database_subnet = { "ap-northeast-1a" : "10.0.201.0/24", "ap-northeast-1c" : "10.0.202.0/24" }

ec2_instance_az = "ap-northeast-1a"