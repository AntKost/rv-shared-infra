output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "mqtt_tg_blue_arn" {
  value = aws_lb_target_group.mqtt_tg_blue.arn
}
output "mqtt_tg_blue_name" {
  value = aws_lb_target_group.mqtt_tg_blue.name
}
output "mqtt_tg_green_arn" {
  value = aws_lb_target_group.mqtt_tg_green.arn
}
output "mqtt_tg_green_name" {
  value = aws_lb_target_group.mqtt_tg_green.name
}

output "redis_tg_blue_arn" {
  value = aws_lb_target_group.redis_tg_blue.arn
}
output "redis_tg_blue_name" {
  value = aws_lb_target_group.redis_tg_blue.name
}
output "redis_tg_green_arn" {
  value = aws_lb_target_group.redis_tg_green.arn
}
output "redis_tg_green_name" {
  value = aws_lb_target_group.redis_tg_green.name
}

output "alb_mqtt_listener_arn" {
  value = aws_lb_listener.mqtt.arn
}

output "alb_redis_listener_arn" {
  value = aws_lb_listener.redis.arn
}