variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for the cluster"
  type        = string
  default     = "t2.micro"
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 0
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "ecs_ami_id" {
  description = "AMI ID for the ECS-optimized AMI"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
  default     = "" # Optional: Provide if you need SSH access
}

variable "alb_sg_id" {
  description = "The Security Group ID attached to the ALB"
  type        = string
}

variable "ecs_instances_sg_id" {
  description = "The Security Group ID attached to the ECS instances"
  type        = string
}

variable "rds_sg_id" {
  description = "The Security Group ID attached to the RDS"
  type        = string
}

variable "allowed_ports" {
  description = "Ports to allow ingress from ALB on"
  type = list(number)
}
