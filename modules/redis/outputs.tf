output "redis_service_name" {
  value = aws_ecs_service.redis.name
}

output "redis_service_discovery_arn" {
  value = aws_service_discovery_service.redis.arn
}
