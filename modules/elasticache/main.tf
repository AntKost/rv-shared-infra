resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.redis_cluster_id}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.redis_cluster_id}-subnet-group"
  }
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = var.redis_cluster_id
  engine               = "redis"
  engine_version       = var.redis_engine_version
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_clusters
  port                 = var.redis_port
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [var.security_group_ids]
  parameter_group_name = "default.redis6.x"

  apply_immediately = true

  tags = {
    Name = var.redis_cluster_id
  }
}
