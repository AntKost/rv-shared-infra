variable "redis_cluster_id" {
  description = "Identifier for the Redis cluster"
  type        = string
  default     = "road-vision-redis"
}

variable "redis_node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "6.x"
}

variable "redis_num_cache_clusters" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "VPC ID where the Redis cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redis cluster"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the Redis cluster"
  type        = string
}

variable "redis_port" {
  description = "Port number on which Redis will accept connections"
  type        = number
  default     = 6379
}

variable "enable_redis_auth_token" {
  description = "Enable Redis AUTH token for authentication"
  type        = bool
  default     = false
}