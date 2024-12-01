output "mqtt_service_name" {
  value = aws_ecs_service.mqtt.name
}

output "mqtt_service_discovery_arn" {
  value = aws_service_discovery_service.mqtt.arn
}
