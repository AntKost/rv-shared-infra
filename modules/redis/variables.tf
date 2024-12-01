variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
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

variable "ecs_instance_security_group_id" {
  description = "The Security Group ID attached to ECS instances"
  type        = string
}
