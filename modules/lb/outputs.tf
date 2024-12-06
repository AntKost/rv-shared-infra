output "lb_dns_name" {
  value = aws_lb.this.dns_name
}

output "lb_arn" {
  value = aws_lb.this.arn
}

output "mqtt_tg_blue_arn" {
  value = aws_lb_target_group.mqtt_tg_blue.arn
}

output "mqtt_tg_blue_name" {
  value = aws_lb_target_group.mqtt_tg_blue.name
}

output "lb_mqtt_listener_arn" {
  value = aws_lb_listener.mqtt.arn
}

output "lb_mqtt_test_listener_arn" {
  value = aws_lb_listener.mqtt_green.arn
}
