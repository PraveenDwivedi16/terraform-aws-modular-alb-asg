variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "cloud-scale"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.20.0/24"]
}

variable "availability_zones" {
  description = "Availability zones list"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.small"
}

variable "asg_min_size" {
  description = "Minimum ASG capacity"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum ASG capacity"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired ASG capacity"
  type        = number
  default     = 3
}
