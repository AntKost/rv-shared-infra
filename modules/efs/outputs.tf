output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.road_vision_efs.id
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.road_vision_efs.dns_name
}

output "efs_mount_target_ids" {
  description = "List of EFS mount target IDs"
  value       = aws_efs_mount_target.road_vision_efs_mt[*].id
}

output "efs_security_group_ids" {
  description = "List of security group IDs associated with EFS mount targets"
  value       = aws_security_group.efs_sg[*].id
}

output "efs_access_policy_arn" {
  value = aws_iam_policy.efs_access_policy.arn
}
