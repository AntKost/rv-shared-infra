# Security Group for Redis Service
resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Allow Redis traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Redis Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "redis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "redis"
    image = "redis:latest"
    portMappings = [{
      containerPort = 6379
      hostPort      = 6379
      protocol      = "tcp"
    }]
  }])

  execution_role_arn = var.ecs_task_execution_role
}

# Redis ECS Service
resource "aws_ecs_service" "this" {
  name            = "redis-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.redis_sg.id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
