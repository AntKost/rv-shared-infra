variable "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  type        = string
}

variable "ecs_task_execution_role" {
  description = "The ARN of the ECS task execution role"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}
