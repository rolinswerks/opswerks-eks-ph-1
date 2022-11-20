# See Almanac docs for more details regarding Github OIDC prodiver
# Enable this only if the Github OIDC provider is not yet created
# resource "aws_iam_openid_connect_provider" "github" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e", "6938fd4d98bab03faadb97b34396831e3780aea1"]
# }

variable "organization" {
  description = "Name of the Github Organization."
  type        = string
  default     = "opswerks-swg"
}

# Items to be added for additional project
# 1. ECRs
# 2. IAM Role Policies Content
# 3. IAM Role Policies Actions
# 4. IAM Role Policies
# 5. IAM Roles
# 6. IAM Roles and Policies Attachment
# 7. Created Objects Reflected on Terraform Output


### opswerks-eks-ph-1 Github and ECR details ###
# List of ECRs #
resource "aws_ecr_repository" "opswerks-eks-ph-1" {
  name = "opswerks-eks-ph-1"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(
    {Project = "Default EKS Cluster"}, 
    local.tags
  )
}


# List of IAM Role Policies Content #
data "aws_iam_policy_document" "opswerks_eks_ph_1_gh_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      #identifiers = [aws_iam_openid_connect_provider.github.arn]
      identifiers = ["arn:aws:iam::272853297737:oidc-provider/token.actions.githubusercontent.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.organization}/opswerks-eks-ph-1:*"]
    }
  }
}

# List of IAM Role Policies Actions #
data "aws_iam_policy_document" "opswerks-eks-ph-1-gh-actions" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeImages",
    ]
    resources = [aws_ecr_repository.opswerks-eks-ph-1.arn,]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }
}

# List of IAM Role Policies #
resource "aws_iam_policy" "opswerks-eks-ph-1-gh-actions" {
  name        = "github-actions-opswerks-eks-ph-1"
  description = "Grant Github Actions the ability to push to Opswerks EKS repo from opswerks-eks-ph-1"
  policy      = data.aws_iam_policy_document.opswerks-eks-ph-1-gh-actions.json

  tags = merge(
    {Project = "Default EKS Cluster"}, 
    local.tags
  )
}

# List of IAM Roles #
resource "aws_iam_role" "opswerks-eks-ph-1-gh-actions" {
  name               = "${var.organization}-ci-opswerks-eks-ph-1"
  assume_role_policy = data.aws_iam_policy_document.opswerks_eks_ph_1_gh_assume_role.json

  tags = merge(
    {Project = "Default EKS Cluster"}, 
    local.tags
  )
}

# List of IAM Roles and Policies Attachment #
resource "aws_iam_role_policy_attachment" "opswerks-eks-ph-1-gh-actions" {
  role       = aws_iam_role.opswerks-eks-ph-1-gh-actions.name
  policy_arn = aws_iam_policy.opswerks-eks-ph-1-gh-actions.arn

  tags = merge(
    {Project = "Default EKS Cluster"}, 
    local.tags
  )
}

# List of Created Objects Reflected on Terraform Output #
output "opswerks-eks-ph-1-gh-actions_role" {
  value = aws_iam_role.github_actions.arn
}