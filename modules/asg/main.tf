# 1. Fetch Latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# 2. EC2 Launch Template with IMDSv2 Security & User Data Bootstrapping
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.asg_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = upper(var.environment)
  }))

  # Enforce IMDSv2 for high cloud security (CIS benchmark)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name}-${var.environment}-web-instance"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 3. High Availability Multi-AZ Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name_prefix         = "${var.project_name}-${var.environment}-asg-"
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [var.target_group_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  force_delete     = true

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  # Zero-downtime rolling updates strategy
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg-node"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# 4. Target Tracking Auto Scaling Policy (Scale on CPU > 70%)
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.project_name}-${var.environment}-cpu-policy"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
