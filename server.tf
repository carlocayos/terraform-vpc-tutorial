data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "bastion_host_sg" {
  name   = "bastion_host_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    // Not the safest thing to do, but you can replace
    // this with your public IP address - x.x.x.x.x/32
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-bastion-host-security-group"
  }
}

resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.public_subnet[var.ec2_instance_az].id
  associate_public_ip_address = true
  key_name                    = "my-keypair" // TODO: Change this
  vpc_security_group_ids      = [aws_security_group.bastion_host_sg.id]

  tags = {
    Name = "My Bastion Host"
  }
}