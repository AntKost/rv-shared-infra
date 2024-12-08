output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}

output "ecs_cluster_id" {
  value = module.ecs_cluster.ecs_cluster_id
}

output "ecs_cluster_name" {
  value = module.ecs_cluster.ecs_cluster_name
}

output "lb_dns_name" {
  value = module.lb.lb_dns_name
}

output "lb_arn" {
  value = module.lb.lb_arn
}

output "service_discovery_namespace_id" {
  value = module.ecs_cluster.service_discovery_namespace_id
}

output "ecs_task_execution_role_arn" {
  value = module.ecs_cluster.ecs_task_execution_role_arn
}

output "ecs_task_execution_role_name" {
  value = module.ecs_cluster.ecs_task_execution_role_name
}

output "mqtt_service_discovery_name" {
  value = module.mqtt.mqtt_service_discovery_name
}

output "ecs_instances_sg_id" {
  value = module.security_groups.ecs_instances_sg_id
}

output "lb_sg_id" {
  value = module.security_groups.lb_sg_id
}

output "mqtt_sg_id" {
  value = module.security_groups.mqtt_sg_id
}

output "rds_sg_id" {
  value = module.security_groups.rds_sg_id
}

output "redis_sg_id" {
  value = module.security_groups.redis_sg_id
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "mqtt_task_definition_arn" {
  value = module.mqtt.mqtt_task_definition_arn
}

output "codedeploy_mqtt_app_name" {
  value = module.mqtt.codedeploy_app_name
}

output "codedeploy_mqtt_deployment_group_name" {
  value = module.mqtt.codedeploy_deployment_group_name
}

output "asg_capacity_provider" {
  value = module.ecs_cluster.asg_capacity_provider
}

output "codedeploy_role_arn" {
  value = aws_iam_role.codedeploy_role.arn
}