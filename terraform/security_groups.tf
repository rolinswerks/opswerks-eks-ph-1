resource "aws_security_group" "postgres_rds_security_group" {
  name        = "allow_postgres"
  description = "Allow postgres inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress = [
    {
      description      = "postgres"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      security_groups  = [
        aws_security_group.opswerks-eks-ph-ngrp.id,
      ]
      cidr_blocks      = null
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      self             = null
    }
  ]
}

resource "aws_security_group" "opswerks-eks-ph-ngrp" {
  name_prefix = "opswerks-eks-ph-ngrp"
  description = "Allow SSH for the nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
