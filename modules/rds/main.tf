# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "rv-subnet-group"
  description = "Subnet group created for PostgreSQL DB of road_vision project"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rv-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier              = "postgresql"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "16.3"
  instance_class          = "db.t4g.micro"
  db_name                 = "road_vision"
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = true
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.rds_sg_id]
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false
  auto_minor_version_upgrade = false
  backup_retention_period = 0
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  max_allocated_storage = 0
  network_type = "IPV4"
  port = 5432
  storage_encrypted = true



  tags = {
    Name = "postgresql"
  }
}
