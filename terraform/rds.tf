resource "random_password" "rds_password" {
  length           = 16
  special          = false
  lifecycle {
    ignore_changes = all
  }
}
resource "aws_db_subnet_group" "default-rds-subnets" {
  name       = "default-rds-subnets"
  subnet_ids = flatten(module.vpc.database_subnets)

  tags = {
    Name = "Default RDS subnet groups for Opswerks EKS"
  }
}
resource "aws_db_parameter_group" "postgres-db-params" {
  name   = "postgres11"
  family = "postgres11"

  parameter {
    name  = "autovacuum"
    value = 1
  }

  parameter {
    name  = "client_encoding"
    value = "utf8"
  }
}

### START: opswerks-eks-ph-1 RDS details ###
resource "aws_db_instance" "awsospwerkseksph1db" {
  allocated_storage    = 30
  engine               = "postgres"
  engine_version       = "11.16"
  instance_class       = "db.t2.small"
  name                 = "awsospwerkseksph1db"
  identifier           = "awsospwerkseksph1db"
  username             = "ospwerkseksph1db"
  password             = random_password.rds_password.result
  parameter_group_name = aws_db_parameter_group.postgres-db-params.name
  skip_final_snapshot  = true
  port     = "5432"
  iam_database_authentication_enabled = true
  vpc_security_group_ids = [aws_security_group.postgres_rds_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.default-rds-subnets.id
  deletion_protection = false
  backup_retention_period = 35
  backup_window = "02:00-03:00"
  publicly_accessible = var.db_publicly_accessible
  
  tags = merge(
    {Project = "Default EKS Cluster"}, 
    local.tags
  )
}
### END: opswerks-eks-ph-1 RDS details ###

