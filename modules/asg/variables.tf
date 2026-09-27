variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "asg_security_group_id" {
  description = "Security Group ID for ASG EC2 instances"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets to launch the ASG instances in"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group to attach instances to"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired number of instances in the ASG"
  type        = number
  default     = 2
}
