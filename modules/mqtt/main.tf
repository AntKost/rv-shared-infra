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

resource "aws_codedeploy_app" "mqtt" {
  name        = "mqtt-codedeploy-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "mqtt" {
  app_name              = aws_codedeploy_app.mqtt.name
  deployment_group_name = "mqtt-deployment-group"
  service_role_arn      = var.codedeploy_role_arn

  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = aws_ecs_service.mqtt.name
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
        name = var.mqtt_tg_blue_name
      }

      target_group {
        name = var.mqtt_tg_green_name
      }

      prod_traffic_route {
        listener_arns = [var.alb_mqtt_listener_arn]
      }
    }
  }
}


# MQTT Task Definition
resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "480"

  container_definitions = jsonencode([{
    name  = "mqtt"
    image = "eclipse-mosquitto:latest"
    portMappings = [{
      containerPort = 1883
      hostPort      = 1883
      protocol      = "tcp"
    },
    {
      containerPort = 9001
      hostPort      = 9001
      protocol      = "tcp"
    }]
    mountPoints = [
      {
        sourceVolume  = "efs_volume"
        containerPath = "/mqtt"
        readOnly      = false
      }
    ]
    healthCheck = {
      command     = ["CMD", "wget --no-verbose --tries=1 --spider http://localhost:9001/ || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])

  volume {
    name = "efs_volume"

    efs_volume_configuration {
      file_system_id     = var.efs_file_system_id
      root_directory     = "/mqtt"
      transit_encryption = "ENABLED"
    }
  }

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

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}
