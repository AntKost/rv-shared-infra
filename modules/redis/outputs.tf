output "redis_security_group_id" {
  value = aws_security_group.redis_sg.id
}

output "redis_service_name" {
  value = aws_ecs_service.this.name
}
