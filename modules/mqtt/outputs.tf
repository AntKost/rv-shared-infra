output "mqtt_service_name" {
  value = aws_ecs_service.mqtt.name
}

output "mqtt_service_discovery_arn" {
  value = aws_service_discovery_service.mqtt.arn
}

output "mqtt_service_discovery_name" {
  value = aws_service_discovery_service.mqtt.name
}

output "mqtt_sg_id" {
  value = aws_security_group.mqtt_sg.id
}