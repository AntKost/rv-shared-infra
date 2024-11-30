# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "rv-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "rv-subnet-group"
  }
}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow database access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust this for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  identifier              = "postgresql"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "13"
  instance_class          = "db.t4g.micro"
  db_name                 = "road_vision"
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = true
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  deletion_protection     = false
  multi_az                = false # For cost optimization

  tags = {
    Name = "postgresql"
  }
}
