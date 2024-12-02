variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "road-vision-cluster"
}

variable "vpc_id" {
  type = string
}

variable "allowed_ports" {
  type = list(number)
}

variable "my_ip" {
  type = string
  sensitive = true
}