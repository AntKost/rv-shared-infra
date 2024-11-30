# Security Group for MQTT Service
resource "aws_security_group" "mqtt_sg" {
  name        = "mqtt-sg"
  description = "Allow MQTT traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 1883
    to_port     = 1883
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

# MQTT Task Definition
resource "aws_ecs_task_definition" "this" {
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
resource "aws_ecs_service" "this" {
  name            = "mqtt-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [aws_security_group.mqtt_sg.id]
    assign_public_ip = false
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Add load balancer configuration if exposing via ALB
}
