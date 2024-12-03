output "redis_service_name" {
  value = aws_ecs_service.redis.name
}

output "redis_service_discovery_arn" {
  value = aws_service_discovery_service.redis.arn
}

output "redis_service_discovery_name" {
  value = aws_service_discovery_service.redis.name
}

output "codedeploy_app_name" {
  value = aws_codedeploy_app.redis.name
}

output "codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.redis.deployment_group_name
}

output "redis_task_definition_arn" {
  value = aws_ecs_task_definition.redis.arn
}
