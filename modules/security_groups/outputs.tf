output "alb_security_group_id" {
  description = "ID of the Application Load Balancer security group"
  value       = aws_security_group.alb_sg.id
}

output "asg_security_group_id" {
  description = "ID of the Auto Scaling Group EC2 security group"
  value       = aws_security_group.asg_sg.id
}
