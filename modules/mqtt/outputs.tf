output "mqtt_security_group_id" {
  value = aws_security_group.mqtt_sg.id
}

output "mqtt_service_name" {
  value = aws_ecs_service.this.name
}
