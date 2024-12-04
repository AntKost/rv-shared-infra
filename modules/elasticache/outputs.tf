output "redis_endpoint" {
  description = "Redis cluster endpoint address"
  value       = aws_elasticache_cluster.redis_cluster.cache_nodes[0].address
}

output "redis_port" {
  description = "Redis cluster endpoint port"
  value       = aws_elasticache_cluster.redis_cluster.cache_nodes[0].port
}
