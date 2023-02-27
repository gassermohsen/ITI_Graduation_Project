resource "aws_instance" "ec2-terraform" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  associate_public_ip_address = "true"
  key_name = var.key_name
  vpc_security_group_ids = [var.sec_group]
  tags = {
    Name = var.name
  }
}

