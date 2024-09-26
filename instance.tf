# amazon linux 2003 image
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM Role profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "mongo_profile"
  role = var.role_name
}

# ec2 instance for mongo
resource "aws_instance" "mongo" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  user_data = file("install.sh")
  tags = {
    Name = "mongo-tf"
  }
  monitoring = true
  root_block_device {
    encrypted = true
  }
}