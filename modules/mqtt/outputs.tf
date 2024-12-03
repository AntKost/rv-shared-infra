output "mqtt_service_name" {
  value = aws_ecs_service.mqtt.name
}

output "mqtt_service_discovery_arn" {
  value = aws_service_discovery_service.mqtt.arn
}

output "mqtt_service_discovery_name" {
  value = aws_service_discovery_service.mqtt.name
}

output "codedeploy_app_name" {
  value = aws_codedeploy_app.mqtt.name
}

output "codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.mqtt.deployment_group_name
}

output "mqtt_task_definition_arn" {
  value = aws_ecs_task_definition.mqtt.arn
}