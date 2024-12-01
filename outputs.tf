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

# Add other outputs as needed
