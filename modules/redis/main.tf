# Service Discovery Service for Redis
resource "aws_service_discovery_service" "redis" {
  name = "redis"

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      type = "A"
      ttl  = 60
    }
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# Security Group for Redis Service
resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Allow Redis traffic"
  vpc_id      = var.vpc_id

  # Ingress rules - allow inbound Redis traffic from ECS instances
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.ecs_instance_security_group_id]
    description     = "Allow Redis traffic from ECS instances"
  }

  # Egress rules - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "redis-sg"
  }
}

# Redis Task Definition
resource "aws_ecs_task_definition" "redis" {
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
resource "aws_ecs_service" "redis" {
  name            = "redis-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [aws_security_group.redis_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
