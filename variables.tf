variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "db_username" {
  type = string
  default = "postgres"
}

variable "db_password" {
  description = "The password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  type = string
  default     = "road-vision-cluster"
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
  default     = "" # Optional: Provide if SSH access is needed
}

variable "allowed_ports" {
  description = "Ports to allow ingress from lb on"
  type = list(number)
  default     = [1883, 1993, 1994, 6379, 8000, 8080, 8001, 9001, 9090]
}

variable "my_ip" {
  type = string
  sensitive = true
}

# Add any other global variables if needed
