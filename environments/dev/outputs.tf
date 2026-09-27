output "alb_public_url" {
  description = "Public URL of the Application Load Balancer"
  value       = "http://${module.alb.alb_dns_name}"
}

output "vpc_id" {
  description = "VPC ID of the environment"
  value       = module.vpc.vpc_id
}

output "asg_name" {
  description = "Auto Scaling Group Name"
  value       = module.asg.asg_name
}

output "target_group_arn" {
  description = "ALB Target Group ARN"
  value       = module.alb.target_group_arn
}
