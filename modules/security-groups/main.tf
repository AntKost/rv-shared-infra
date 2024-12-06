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
    cidr_blocks = [var.my_ip]
    description = "Allow SSH access"
  }

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
    description = "Allow RDS access"
  }

  ingress {
    from_port = 2049
    to_port = 2049
    protocol = "tcp"
    security_groups = [aws_security_group.efs_sg.id]
    description = "Allow EFS access"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
    description = "Allow self access"
  }

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      from_port                = ingress.value
      to_port                  = ingress.value
      protocol                 = "tcp"
      security_groups          = [aws_security_group.alb_sg.id]
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

# Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = var.vpc_id

  # Egress rules - allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "external_view" {
  security_group_id = aws_security_group.alb_sg.id

  from_port   = 8001
  to_port     = 8001
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "external_agent" {
  security_group_id = aws_security_group.alb_sg.id

  from_port   = 1883
  to_port     = 1883
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "external_agent" {
  security_group_id = aws_security_group.alb_sg.id

  from_port   = 9001
  to_port     = 9001
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.ecs_instances_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "internal_ecs" {
  security_group_id = aws_security_group.alb_sg.id

  ip_protocol = "-1"
  referenced_security_group_id = aws_security_group.ecs_instances_sg.id
}

# Security Group for EFS
resource "aws_security_group" "efs_sg" {
  name        = "efs-sg"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "efs-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "efs" {
  security_group_id = aws_security_group.efs_sg.id

  from_port   = 2049
  to_port     = 2049
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.ecs_instances_sg.id
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
    security_groups = [aws_security_group.ecs_instances_sg.id]
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

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "postgresql-sg"
  description = "Allow database access"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "external_access" {
  security_group_id = aws_security_group.rds_sg.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
  cidr_ipv4   = var.my_ip
}

resource "aws_vpc_security_group_ingress_rule" "ecs_access" {
  security_group_id = aws_security_group.rds_sg.id

  from_port   = 5432
  to_port     = 5432
  ip_protocol = "tcp"
  referenced_security_group_id = aws_security_group.ecs_instances_sg.id
}

# Security Group for Redis Service
resource "aws_security_group" "redis_sg" {
  name        = "redis-sg"
  description = "Security group for Redis cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_instances_sg.id]
    description     = "Allow Redis access from microservices"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "redis-sg"
  }
}
