# Data source to get the latest ECS-optimized AMI if not provided
data "aws_ami" "ecs_ami" {
  count = var.ecs_ami_id == "" ? 1 : 0

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  most_recent = true
  owners      = ["amazon"]
}

# Use provided AMI ID or the latest ECS-optimized AMI
locals {
  ami_id = var.ecs_ami_id != "" ? var.ecs_ami_id : data.aws_ami.ecs_ami[0].id
}

# Security Group for ECS instances
resource "aws_security_group" "ecs_instances_sg" {
  name        = "${var.cluster_name}-instances-sg"
  description = "Security group for ECS instances"
  vpc_id      = var.vpc_id

  # Ingress rules - restrict inbound traffic
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["176.100.25.70/32"] # Replace with your IP or trusted CIDR blocks
    description = "Allow SSH access"
  }

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port                = ingress.value
      to_port                  = ingress.value
      protocol                 = "tcp"
      security_groups          = [var.alb_security_group_id]
      description              = "Allow traffic from ALB on port ${ingress.value}"
      self                     = false
    }
  }

  # Egress rules - allow outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-instances-sg"
  }
}

# IAM Role for ECS Instances
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.cluster_name}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach policies to the IAM role
resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.cluster_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# Attach policies to the ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Instance Profile
resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.cluster_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

# Launch Template
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${var.cluster_name}-launch-template-"
  image_id      = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_pair_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    security_groups             = [aws_security_group.ecs_instances_sg.id]
    associate_public_ip_address = true
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.cluster_name}-instance"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ecs_asg" {
  name                      = "${var.cluster_name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.public_subnet_ids
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "asg_capacity_provider" {
  name = "${var.cluster_name}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 4
    }

    managed_termination_protection = "ENABLED"
  }
}

# Attach Capacity Provider to ECS Cluster
resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name       = aws_ecs_cluster.this.name
  capacity_providers = [aws_ecs_capacity_provider.asg_capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg_capacity_provider.name
    weight            = 1
    base              = 0
  }
}

# Service Discovery Namespace for ECS Service Discovery
resource "aws_service_discovery_private_dns_namespace" "service_discovery" {
  name        = "${var.cluster_name}.local"
  description = "Service discovery namespace for ${var.cluster_name}"
  vpc         = var.vpc_id
}