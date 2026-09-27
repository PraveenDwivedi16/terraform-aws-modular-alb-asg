# 1. Application Load Balancer Security Group (Public facing)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Allows inbound HTTP traffic to ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow inbound HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. Auto Scaling Group EC2 Security Group (Strict Least-Privilege)
resource "aws_security_group" "asg_sg" {
  name        = "${var.project_name}-${var.environment}-asg-sg"
  description = "Allows inbound HTTP traffic ONLY from the ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP only from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow all outbound traffic for software updates"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-asg-sg"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
