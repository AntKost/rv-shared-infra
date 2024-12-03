variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "efs_name" {
  description = "Name of the EFS file system"
  type        = string
  default     = "road-vision-efs"
}

variable "efs_performance_mode" {
  description = "Performance mode for EFS"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "Throughput mode for EFS"
  type        = string
  default     = "bursting"
}

variable "efs_provisioned_throughput_in_mibps" {
  description = "Provisioned throughput for EFS (required if throughput_mode is provisioned)"
  type        = number
  default     = 0  # Set to desired value if using provisioned mode
}

variable "efs_encryption" {
  description = "Enable encryption at rest for EFS"
  type        = bool
  default     = true
}

variable "efs_kms_key_id" {
  description = "KMS Key ID for EFS encryption (if encryption is enabled and using KMS)"
  type        = string
  default     = ""
}

variable "efs_tags" {
  description = "Tags to apply to the EFS file system"
  type        = map(string)
  default     = {
    Environment = "production"
    Project     = "road-vision"
  }
}

variable "efs_subnet_ids" {
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "efs_security_group_ids" {
  description = "List of security group IDs to associate with EFS mount targets"
  type        = list(string)
}
