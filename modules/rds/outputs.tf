output "db_endpoint" {
  value = aws_db_instance.postgresql.address
}

output "db_security_group_id" {
  value = aws_security_group.rds_sg.id
}
