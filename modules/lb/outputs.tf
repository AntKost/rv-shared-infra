output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "mqtt_tg_arn" {
  value = aws_lb_target_group.mqtt_tg.arn
}

output "redis_tg_arn" {
  value = aws_lb_target_group.redis_tg.arn
}
