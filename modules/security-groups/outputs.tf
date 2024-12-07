output "ecs_instances_sg_id" {
  value = aws_security_group.ecs_instances_sg.id
}

output "lb_sg_id" {
  value = aws_security_group.lb_sg.id
}

output "mqtt_sg_id" {
  value = aws_security_group.mqtt_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}

output "efs_sg_id" {
  value = aws_security_group.efs_sg.id
}