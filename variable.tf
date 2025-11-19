variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 3
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "scale_out_cpu_threshold" {
  type    = number
  default = 30
}

variable "scale_in_cpu_threshold" {
  type    = number
  default = 20
}

variable "scale_out_memory_threshold" {
  type    = number
  default = 5
}

variable "vpc_id" {
  type    = string
  default = "vpc-04a3ffe1857e68bdf"
}


variable "subnet_ids" {
  type = list(string)
  default = [
    "subnet-0335cc41a0f6775a6",
    "subnet-0e7aae51c6c968eef",
    "subnet-04f5ce02cfadac81b"
  ]
}

variable "key_name" {
  type    = string
  default = "robo"
}

