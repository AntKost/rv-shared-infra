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

# Redis Task Definition
resource "aws_ecs_task_definition" "redis" {
  family                   = "redis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"

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
    security_groups = [var.redis_sg_id, var.ecs_instances_sg_id]
  }

  load_balancer {
    target_group_arn = var.redis_tg_arn
    container_name = "redis"
    container_port = 6379
  }

  service_registries {
    registry_arn = aws_service_discovery_service.redis.arn
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
