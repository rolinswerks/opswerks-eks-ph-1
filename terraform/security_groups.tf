resource "aws_security_group" "opswerks_eks_ph_rds_security_group" {
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
        aws_security_group.ngrp-1.id,
      ]
      cidr_blocks      = null
      ipv6_cidr_blocks = []
      prefix_list_ids  = null
      self             = null
    }
  ]
}

resource "aws_security_group" "ngrp-1" {
  name_prefix = "ngrp-1"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vela-prod" {
  name_prefix = "vela-prod"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
}
