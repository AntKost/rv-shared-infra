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

resource "aws_codedeploy_app" "redis" {
  name        = "redis-codedeploy-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "redis" {
  app_name              = aws_codedeploy_app.redis.name
  deployment_group_name = "redis-deployment-group"
  service_role_arn      = var.codedeploy_role_arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = aws_ecs_service.redis.name
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                              = "TERMINATE"
      termination_wait_time_in_minutes    = 5
    }

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = var.redis_tg_blue_name
      }

      target_group {
        name = var.redis_tg_green_name
      }

      prod_traffic_route {
        listener_arns = [var.alb_redis_listener_arn]
      }
    }
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
    healthCheck = {
      command     = ["CMD", "redis-cli","ping"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
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

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}
