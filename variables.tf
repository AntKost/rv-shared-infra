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

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
  default     = "" # Optional: Provide if SSH access is needed
}

variable "allowed_ports" {
  description = "Ports to allow ingress from ALB on"
  type = list(number)
  default     = [22, 1883, 8000, 8001]
}

# Add any other global variables if needed
