locals {
  tags = {
    Terraform = "true"
    Environment = var.environment
    Cluster = var.cluster_name
    team = "iron"
    env = "production"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.26.6"
  cluster_name    = var.eks_name
  cluster_version = "1.22"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_group_defaults = {
    attach_cluster_primary_security_group = true
    create_security_group = false
  }

  cluster_enabled_log_types = ["api"]
  manage_aws_auth_configmap = true

### Append additional roles for new project on below list ###
# These roles provides access to EKS cluster with different level of permission based on the assumed group. 
# Most of the groups prefixed with "system:" are Kubernetes defaults and can be checked from offical K8s docs.
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
    {
      rolearn  = aws_iam_role.opswerks-eks-ph-1-gh-actions.name
      username = "opswerks-eks-ph-1-user",
      groups   = ["system:masters"]
    },

    # Add more roles below this #
    {
      rolearn  = aws_iam_role.swg-app-1-iam-role.name
      username = "swg-app-1-user",
      groups   = ["swg-app-1-users"]
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
        aws_security_group.opswerks-eks-ph-ngrp.id
      ]

      labels = {
        application = "opswerks-eks-defalt-components"
      }
    },
  }

  tags = merge(
    {"alpha.eksctl.io/cluster-oidc-enabled" = "true"},
    {"kubernetes.io/cluster/${var.eks_name}" = "owned"}, 
    {Project = "Default EKS Cluster"},
    local.tags
  )
}

resource "kubernetes_namespace" "swg-app-1-ns" {
  metadata {
    labels = {
      application = "swg-app-1"
    }

    name = "swg-app-1-ns"
  }
}

resource "kubernetes_role" "swg-app-1-role" {
  metadata {
    name = "swg-app-1-role"
    labels = {
      application = "swg-app-1"
    }
    namespace = "swg-app-1-ns"
  }

  rule {
    api_groups     = ["*"]
    resources      = ["*"]
    resource_names = ["*"]
    verbs          = ["*"]
  }

  depends_on = [
    kubernetes_namespace.swg-app-1-ns
  ]
}

### START: swg-app-1 Roles and RoleBindings ###
resource "kubernetes_role_binding" "swg-app-1-role-binding" {
  metadata {
    name      = "swg-app-1-role-binding"
    namespace = "swg-app-1-ns"
    labels    = {
      application = "swg-app-1"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "swg-app-1-role"
  }

  subject {
    kind      = "Group"
    name      = "swg-app-1-users"
    api_group = "rbac.authorization.k8s.io"
    namespace = "swg-app-1-ns"
  }
}

resource "aws_iam_role" "swg-app-1-iam-role" {
  name = "OpswerksAppsEKSRole-${var.environment}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::272853297737:root"
        }
      },
    ]
  })

  max_session_duration = 14400

  tags = merge(
    {Project = "swg-app-1"}, 
    local.tags
  )
}
### END: swg-app-1 Roles and RoleBindings ###

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
