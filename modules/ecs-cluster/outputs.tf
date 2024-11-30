output "ecs_cluster_id" {
  value = aws_ecs_cluster.this.id
}

output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
