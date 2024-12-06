# Application Load Balancer
resource "aws_lb" "this" {
  name               = "road-vision-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_sg_id]

  tags = {
    Name = "road-vision-alb"
  }
}

resource "aws_lb_target_group" "mqtt_tg_blue" {
  name        = "mqtt-tg-blue"
  port        = 1883
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
    port                = 9001
  }

  tags = {
    Name = "mqtt-tg"
  }
}

resource "aws_lb_target_group" "mqtt_tg_green" {
  name        = "mqtt-tg-green"
  port        = 1883
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
    port                = 9001
  }

  tags = {
    Name = "mqtt-tg"
  }
}

resource "aws_lb_listener" "mqtt" {
  load_balancer_arn = aws_lb.this.arn
  port              = 1883
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt_tg_blue.arn
  }

  tags = {
    Name = "mqtt-listener"
  }
}

resource "aws_lb_listener" "mqtt_green" {
  load_balancer_arn = aws_lb.this.arn
  port              = 9001
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt_tg_green.arn
  }

  tags = {
    Name = "mqtt-listener-green"
  }
}
