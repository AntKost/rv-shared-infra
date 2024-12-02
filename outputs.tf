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

output "alb_dns_name" {
  value = module.lb.alb_dns_name
}

output "alb_arn" {
  value = module.lb.alb_arn
}

output "service_discovery_namespace_id" {
  value = module.ecs_cluster.service_discovery_namespace_id
}

output "ecs_task_execution_role_arn" {
  value = module.ecs_cluster.ecs_task_execution_role_arn
}

output "mqtt_service_discovery_name" {
  value = module.mqtt.mqtt_service_discovery_name
}

output "redis_service_discovery_arn" {
  value = module.redis.redis_service_discovery_arn
}

output "ecs_instances_sg_id" {
  value = module.security_groups.ecs_instances_sg_id
}

output "alb_sg_id" {
  value = module.security_groups.alb_sg_id
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