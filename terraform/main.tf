locals {
  tags = {
    Terraform = "true"
    Environment = var.environment
    Project = var.project_name
    team = "iron"
    env = "production"
  }
}

# module "eks" {
#   depends_on = [
#     module.vpc
#   ]
#   source          = "terraform-aws-modules/eks/aws"
#   version         = "17.24.0"
#   cluster_name    = var.eks_name
#   cluster_version = "1.22"
#   subnets         = module.vpc.private_subnets

#   #vpc_id = module.vpc.vpc_id
#   vpc_id = "vpc-08b754cbb05333fe8"

#   workers_group_defaults = {
#     root_volume_type = "gp2"
#   }

#   worker_groups = [
#     {
#       name                          = "demo-gh-ecr-${var.environment}-worker-group"
#       instance_type                 = var.eks_instance_type
#       asg_desired_capacity          = var.worker_group_size
#       asg_min_size                  = var.worker_group_size
#       asg_max_size                  = var.worker_group_size
#       additional_security_group_ids = [aws_security_group.ngrp-1.id]
#       root_volume_size              = "20"
#     },
#   ]

#   map_users = []

#   map_roles = [
#     {
#       rolearn  = "arn:aws:iam::874481523825:role/AWSReservedSSO_AWSAdministratorAccess_c5a0073e8d914cd0" 
#       username = "AWSReservedSSO_AWSAdministratorAccess_c5a0073e8d914cd0"
#       groups   = ["system:masters"]
#     },
#     {
#       rolearn  = "arn:aws:iam::874481523825:role/AWSReservedSSO_AWSPowerUserAccess_4d31645b215976f8" 
#       username = "AWSReservedSSO_AWSPowerUserAccess_4d31645b215976f8",
#       groups   = ["system:masters"]
#     },
#     {
#       rolearn  = "arn:aws:iam::272853297737:role/opswerks-swg-ci-iron-vela" 
#       username = "opswerks-swg-ci-iron-vela",
#       groups   = ["system:masters"]
#     },
#   ]

#   tags = merge({"alpha.eksctl.io/cluster-oidc-enabled" = "true"}, local.tags)

# }





# resource "aws_eks_addon" "network-vpc" {
#   depends_on = [
#     module.eks
#   ]
#   cluster_name = var.eks_name
#   resolve_conflicts = "OVERWRITE"
#   addon_version     = "v1.11.4-eksbuild.1"
#   addon_name   = "vpc-cni"
# }

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_id
# }

# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_id
# }


# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 18.0"

#   cluster_name    = var.eks_name
#   cluster_version = "1.22"

#   cluster_endpoint_private_access       = true
#   cluster_endpoint_public_access        = true
#   cluster_additional_security_group_ids = [aws_security_group.ngrp-1.id]

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   # aws-auth configmap
#   create_aws_auth_configmap = true
#   manage_aws_auth_configmap = true

#   aws_auth_roles = [
#     {
#       rolearn  = "arn:aws:iam::272853297737:role/AWSReservedSSO_AWSAdministratorAccess_8a596885cf4e646d" 
#       username = "AWSReservedSSO_AWSAdministratorAccess_8a596885cf4e646d"
#       groups   = ["system:masters"]
#     },
#     {
#       rolearn  = "arn:aws:iam::272853297737:role/AWSReservedSSO_AWSPowerUserAccess_70827ce15d04578c" 
#       username = "AWSReservedSSO_AWSPowerUserAccess_70827ce15d04578c",
#       groups   = ["system:masters"]
#     },
#     # {
#     #   rolearn  = "arn:aws:iam::272853297737:role/${module.eks_managed_node_group.aws_iam_role.id}" 
#     #   username = "system:node:{{EC2PrivateDNSName}}",
#     #   groups   = ["system:bootstrappers", "system:nodes"]
#     # },
#   ]

#   cluster_addons = {
#     vpc-cni = {
#       resolve_conflicts = "OVERWRITE",
#       addon_version     = "v1.11.4-eksbuild.1"
#     }
#   }

#   tags = merge(
#     {"alpha.eksctl.io/cluster-oidc-enabled" = "true"},
#     {"kubernetes.io/cluster/${var.eks_name}" = "owned"}, 
#     local.tags
#   )
# }


# module "eks_managed_node_group" {
#   source = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"

#   name            = "ngrp-1"
#   cluster_name    = var.eks_name
#   cluster_version = "1.22"

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   cluster_primary_security_group_id = module.eks.cluster_primary_security_group_id
#   cluster_security_group_id = module.eks.node_security_group_id

#   min_size     = var.worker_group_size
#   max_size     = var.worker_group_size
#   desired_size = var.worker_group_size

#   instance_types = [var.eks_instance_type]

#   tags = merge(
#     {"alpha.eksctl.io/cluster-oidc-enabled" = "true"},
#     {"kubernetes.io/cluster/${var.eks_name}" = "owned"}, 
#     local.tags
#   )
# }


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"

  cluster_name    = var.eks_name
  cluster_version = "1.22"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  cluster_enabled_log_types = ["api"]

  # aws-auth configmap
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::272853297737:role/AWSReservedSSO_AWSAdministratorAccess_8a596885cf4e646d" 
      username = "AWSReservedSSO_AWSAdministratorAccess_8a596885cf4e646d"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::272853297737:role/AWSReservedSSO_AWSPowerUserAccess_70827ce15d04578c" 
      username = "AWSReservedSSO_AWSPowerUserAccess_70827ce15d04578c",
      groups   = ["system:masters"]
    },
  ]

  cluster_addons = {
    vpc-cni = {
      resolve_conflicts = "OVERWRITE",
      addon_version     = "v1.11.4-eksbuild.1"
    },
    coredns = {
      resolve_conflicts = "OVERWRITE",
      addon_version     = "v1.8.7-eksbuild.1"
    },
    kube-proxy = {
      resolve_conflicts = "OVERWRITE",
      addon_version     = "v1.22.11-eksbuild.2"
    },
  }


  eks_managed_node_groups = {
    opswerks-eks-ph = {
      name = "opswerks-eks-ph"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 1
      desired_size = 1

      vpc_security_group_ids = [
        aws_security_group.ngrp-1.id
      ]
    },
    vela-prod = {
      name = "vela-prod"

      instance_types = ["t3.small"]

      min_size     = 2
      max_size     = 2
      desired_size = 2

      vpc_security_group_ids = [
        aws_security_group.vela-prod.id
      ]
    }
  }


  tags = merge(
    {"alpha.eksctl.io/cluster-oidc-enabled" = "true"},
    {"kubernetes.io/cluster/${var.eks_name}" = "owned"}, 
    local.tags
  )
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}