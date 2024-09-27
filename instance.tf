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

# IAM Section

# document trust policy to assume role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# iam role
resource "aws_iam_role" "role" {
  name               = "wizzard_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# iam policy for
resource "aws_iam_policy" "policy" {
  name        = "wizzard_ec2_role_policy"
  description = "Policy for wizzard mongodb instance"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = "${var.s3_arn}/*"
      }
    ]
  })
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

# iam instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "mongo_profile"
  role = aws_iam_role.role.name
}

# Networking Section

# data source for vpc
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

# security group
resource "aws_security_group" "security_group" {
  name        = "wizzard_ec2_mongo_sg"
  description = "Wizzard MongoDB instance"
  vpc_id      = var.vpc_id
  tags = {
    Name = "wizzard_ec2_mongo_sg"
  }
}

# ingress rule for ssh
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.security_group.id
  description       = "Allow SSH from anywhere" 
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# ingress rule for mongodb
resource "aws_vpc_security_group_ingress_rule" "allow_mongo" {
  security_group_id = aws_security_group.security_group.id
  description       = "Allow DB access from VPC"
  cidr_ipv4         = data.aws_vpc.vpc.cidr_block
  from_port         = 27017
  ip_protocol       = "tcp"
  to_port           = 27017
}

# egress rule
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Compute Section

# ec2 instance for mongo
resource "aws_instance" "mongo" {
  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name = var.keypair
  user_data = file("install.sh")
  tags = {
    Name = "mongo-tf"
  }
  monitoring = true
  root_block_device {
    encrypted = true
  }
}