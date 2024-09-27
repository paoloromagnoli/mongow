variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = "vpc-01c86d7bde63e7098"
}

variable "subnet_id" {
  description = "VPC Subnet ID"
  type        = string
  default     = "subnet-0949362bc0190d1df"
}

variable "keypair" {
  description = "Wizzard Key Pair"
  type        = string
  default     = "wizzard_key"
}

variable "s3_arn" {
  description = "S3 Bucket ARN"
  type        = string
  default     = "arn:aws:s3:::wizzard-dev-backup-repo-26092024"
} 