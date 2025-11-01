variable "region" {
  default = "ap-south-1"
}

variable "ami_id" {
  # Amazon Linux 2023 AMI (you can find latest in AWS Console)
  default = "ami-0dee22c13ea7a9a67"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  description = "AWS Key Pair name for SSH"
  default     = "cli"
}
