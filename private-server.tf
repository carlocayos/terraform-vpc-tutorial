resource "aws_security_group" "private_server_sg" {
  name   = "private_server_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_host_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-private-server-security-group"
  }
}

resource "aws_instance" "private_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  # https://github.com/terraform-providers/terraform-provider-aws/issues/7522
  subnet_id              = aws_subnet.private_subnet[var.ec2_instance_az].id
  key_name               = "my-keypair"
  vpc_security_group_ids = [aws_security_group.private_server_sg.id]

  tags = {
    Name = "My Private Server"
  }
}