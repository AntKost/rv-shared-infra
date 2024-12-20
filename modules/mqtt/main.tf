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
        listener_arns = [var.lb_mqtt_listener_arn]
      }

      test_traffic_route {
        listener_arns = [var.lb_mqtt_test_listener_arn]
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "mqtt_log_group" {
  name              = "/ecs/mqtt"
  retention_in_days = 3
}

# MQTT Task Definition
resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "512"
  memory                   = "512"

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
        containerPath = "/mosquitto/config"
        readOnly      = false
      }
    ]
    healthCheck = {
      command     = ["CMD", "mosquitto_sub", "-t", "$SYS/#", "-C", "1", "-i", "healthcheck1", "-W", "3"]
      interval    = 30
      timeout     = 10
      retries     = 5
      startPeriod = 20
    }
    logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.mqtt_log_group.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
  }])

  volume {
    name = "efs_volume"
  
    efs_volume_configuration {
      file_system_id     = var.efs_file_system_id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }

  execution_role_arn = var.ecs_task_execution_role
  task_role_arn      = var.ecs_task_execution_role
}

# MQTT ECS Service
resource "aws_ecs_service" "mqtt" {
  name            = "mqtt-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.mqtt.arn
  desired_count   = 1
  
  capacity_provider_strategy {
    capacity_provider = var.asg_capacity_provider
    weight            = 1
    base              = 100
  }
  
  network_configuration {
    subnets         = var.public_subnet_ids
    security_groups = [var.mqtt_sg, var.ecs_instances_sg_id]
  }

  //load_balancer {
  //  target_group_arn = var.mqtt_tg_arn
  //  container_name = "mqtt"
  //  container_port = 1883
  //}

  service_registries {
    registry_arn = aws_service_discovery_service.mqtt.arn
  }
  
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer, capacity_provider_strategy]
  }
}
