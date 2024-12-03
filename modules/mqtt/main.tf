# Service Discovery Service for MQTT
resource "aws_service_discovery_service" "mqtt" {
  name = "mqtt"

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

# MQTT Task Definition
resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "256"

  container_definitions = jsonencode([{
    name  = "mqtt"
    image = "eclipse-mosquitto:latest"
    portMappings = [
    {
      containerPort = 1883
      hostPort      = 1883
      protocol      = "tcp"
    },
    {
      containerPort = 9001
      hostPort      = 9001
      protocol      = "tcp"
    }
    ]
    healthCheck = {
      command     = ["CMD", "wget --no-verbose --tries=1 --spider http://localhost/ || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])

  execution_role_arn = var.ecs_task_execution_role
}

# MQTT ECS Service
resource "aws_ecs_service" "mqtt" {
  name            = "mqtt-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.mqtt.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [var.mqtt_sg, var.ecs_instances_sg_id]
  }

  load_balancer {
    target_group_arn = var.mqtt_tg_arn
    container_name = "mqtt"
    container_port = 1883
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mqtt.arn
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
