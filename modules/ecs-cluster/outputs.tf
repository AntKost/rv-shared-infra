output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_instance_security_group_id" {
  value = aws_security_group.ecs_instances_sg.id
}

output "ecs_capacity_provider_name" {
  value = aws_ecs_capacity_provider.asg_capacity_provider.name
}

output "service_discovery_namespace_id" {
  value = aws_service_discovery_private_dns_namespace.service_discovery.id
}

output "service_discovery_namespace_arn" {
  value = aws_service_discovery_private_dns_namespace.service_discovery.arn
}