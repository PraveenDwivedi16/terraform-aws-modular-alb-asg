# 1. Modular VPC Infrastructure
module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# 2. Modular Security Group Layer (Strict Least-Privilege Chaining)
module "security_groups" {
  source = "../../modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
}

# 3. Modular Application Load Balancer
module "alb" {
  source = "../../modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
}

# 4. Modular Multi-AZ Auto Scaling Group
module "asg" {
  source = "../../modules/asg"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.instance_type
  asg_security_group_id = module.security_groups.asg_security_group_id
  subnet_ids            = module.vpc.public_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  min_size              = var.asg_min_size
  max_size              = var.asg_max_size
  desired_capacity      = var.asg_desired_capacity
}
