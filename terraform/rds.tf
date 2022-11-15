resource "random_password" "rds_password" {
  length           = 16
  special          = false
  lifecycle {
    ignore_changes = all
  }
}

# # IAM Role for RDS Enhanced Monitoring
# resource "aws_iam_role" "rds-enhanced-monitoring" {

#   name = "rds-enhanced-monitoring"
#   assume_role_policy = jsonencode({
#          Version = "2012-10-17"
#           Statement = [
#             {
#               Action = "sts:AssumeRole"
#               Effect = "Allow"
#               Sid    = ""
#               Principal = {
#                 Service = "monitoring.rds.amazonaws.com"
#              }
#             },
#           ]
#         })

#   managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]

#   tags = {
#     Name = "rds-enhanced-monitoring"
#   }
# }

# # IAM Role Policy for RDS Enhanced Monitoring
# resource "aws_iam_role_policy" "rds-enhanced-monitoring-policy" {

#   depends_on = [aws_iam_role.rds-enhanced-monitoring]

#   name = "test-Enhanced-Monitoring-Policy"
#   role = aws_iam_role.rds-enhanced-monitoring.id

#   policy = jsonencode({
#     "Version": "2012-10-17",
#     "Statement": [{
#             "Sid": "EnableCreationAndManagementOfRDSCloudwatchLogGroups",
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogGroup",
#                 "logs:PutRetentionPolicy"
#             ],
#             "Resource": [
#                 "arn:aws:logs:*:*:log-group:RDS*"
#             ]
#         },
#         {
#             "Sid": "EnableCreationAndManagementOfRDSCloudwatchLogStreams",
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents",
#                 "logs:DescribeLogStreams",
#                 "logs:GetLogEvents"
#             ],
#             "Resource": [
#                 "arn:aws:logs:*:*:log-group:RDS*:log-stream:*"
#             ]
#         }
#     ]
#   })
# }

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


resource "aws_db_instance" "awsospwerkseksph1db" {
  allocated_storage    = 30
  engine               = "postgres"
  engine_version       = "11.16"
  instance_class       = var.instance_type
  name                 = "awsospwerkseksph1db" # Initial DB created inside RDS
  identifier           = "awsospwerkseksph1db" # RDS instance name
  username             = "ospwerkseksph1db"
  password             = random_password.rds_password.result
  parameter_group_name = aws_db_parameter_group.postgres-db-params.name
  skip_final_snapshot  = true
  port     = "5432"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [aws_security_group.opswerks_eks_ph_rds_security_group.id]

  #monitoring_interval = "30"
  #monitoring_role_arn = aws_iam_role.rds-enhanced-monitoring.id

  db_subnet_group_name = aws_db_subnet_group.default-rds-subnets.id
  deletion_protection = false

  backup_retention_period = 35
  backup_window = "02:00-03:00"

  publicly_accessible = var.db_publicly_accessible

  tags = local.tags
}

