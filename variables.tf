variable "subnet_id" {
  description = "VPC Subnet ID"
  type        = string
  default     = "subnet-0ca9476908a603758"
}

variable "security_group_id" {
  description = "Security Group ID"
  type        = string
  default     = "sg-0fe8eabc1a66e3926"
}

variable "role_name" {
  description = "Role ARN"
  type        = string
  default     = "EC2_SSM"
}