output "mqtt_service_name" {
  value = aws_ecs_service.mqtt.name
}

output "mqtt_service_discovery_arn" {
  value = aws_service_discovery_service.mqtt.arn
}

output "mqtt_service_discovery_name" {
  value = aws_service_discovery_service.mqtt.name
}

output "mqtt_task_definition_arn" {
  value = aws_ecs_task_definition.mqtt.arn
}