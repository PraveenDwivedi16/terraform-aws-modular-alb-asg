aws_region          = "us-east-1"
project_name        = "cloud-scale"
environment         = "prod"
vpc_cidr            = "10.1.0.0/16"
public_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24"]
availability_zones  = ["us-east-1a", "us-east-1b"]

instance_type        = "t3.small"
asg_min_size         = 2
asg_max_size         = 6
asg_desired_capacity = 3
