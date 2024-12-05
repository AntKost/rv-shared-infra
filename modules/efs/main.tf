data "aws_caller_identity" "current" {}

resource "aws_efs_file_system" "road_vision_efs" {
  creation_token   = var.efs_name
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode

  # Provisioned throughput only applicable if throughput_mode is provisioned
  provisioned_throughput_in_mibps = var.efs_throughput_mode == "provisioned" ? var.efs_provisioned_throughput_in_mibps : null

  encrypted = var.efs_encryption

  kms_key_id = var.efs_encryption && var.efs_kms_key_id != "" ? var.efs_kms_key_id : null

  tags = var.efs_tags
}

resource "aws_efs_mount_target" "road_vision_efs_mt" {
  count            = length(var.efs_subnet_ids)
  file_system_id   = aws_efs_file_system.road_vision_efs.id
  subnet_id        = var.efs_subnet_ids[count.index]
  security_groups  = var.efs_security_group_ids
}

# EFS Access Policy
resource "aws_iam_policy" "efs_access_policy" {
  name        = "ECS_EFS_Access_Policy"
  description = "IAM policy to allow ECS tasks to access EFS"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:ClientRootAccess"
        ],
        Resource = "arn:aws:elasticfilesystem:${var.aws_region}:${data.aws_caller_identity.current.account_id}:file-system/${aws_efs_file_system.road_vision_efs.id}"
      }
    ]
  })
}
