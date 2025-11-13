variable "vpc_id" {
  description = "VPC ID where resources will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
}
