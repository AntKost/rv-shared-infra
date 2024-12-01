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

# Security Group for MQTT Service
resource "aws_security_group" "mqtt_sg" {
  name        = "mqtt-sg"
  description = "Allow MQTT traffic"
  vpc_id      = var.vpc_id

  # Ingress rules - allow inbound MQTT traffic from ECS instances
  ingress {
    from_port       = 1883
    to_port         = 1883
    protocol        = "tcp"
    security_groups = [var.ecs_instance_security_group_id]
    description     = "Allow MQTT traffic from ECS instances"
  }

  # Egress rules - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mqtt-sg"
  }
}

# MQTT Task Definition
resource "aws_ecs_task_definition" "mqtt" {
  family                   = "mqtt"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([{
    name  = "mqtt"
    image = "eclipse-mosquitto:latest"
    portMappings = [{
      containerPort = 1883
      hostPort      = 1883
      protocol      = "tcp"
    }]
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
    security_groups = [aws_security_group.mqtt_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mqtt.arn
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}
