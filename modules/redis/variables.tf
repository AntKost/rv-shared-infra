variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_task_execution_role" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "service_discovery_namespace_id" {
  description = "The ID of the Service Discovery namespace"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ecs_instances_sg_id" {
  description = "The Security Group ID attached to ECS instances"
  type        = string
}

variable "redis_sg_id" {
  description = "The Security Group ID attached to Redis service"
  type        = string
}

variable "redis_tg_arn" {
  type        = string
}

variable "codedeploy_role_arn" {
  type = string
}

variable "redis_tg_blue_name" {
  type = string
}

variable "redis_tg_green_name" {
  type = string
}

variable "alb_redis_listener_arn" {
  type = string
}