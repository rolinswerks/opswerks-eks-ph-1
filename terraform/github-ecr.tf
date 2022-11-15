variable "repo_name" {
  description = "Name of the ECR Repository- should match the Github repo name."
  type        = string
  default     = "opswerks-eks-ph-1"
}

variable "organization" {
  description = "Name of the Github Organization."
  type        = string
  default     = "opswerks-swg"
}

# See Almanac docs for more details regarding Github OIDC prodiver
# resource "aws_iam_openid_connect_provider" "github" {
#   url             = "https://token.actions.githubusercontent.com"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["a031c46782e6e6c662c2c87c76da9aa62ccabd8e", "6938fd4d98bab03faadb97b34396831e3780aea1"]
# }

# List of repositories
resource "aws_ecr_repository" "opswerks-eks-ph-1" {
  name = "opswerks-eks-ph-1"
  tags = local.tags
}

# resource "aws_ecr_repository" "opswerks-eks-ph-1" {
#   name                 = "opswerks-eks-ph-1"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

data "aws_iam_policy_document" "github_actions_assume_role" {
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
      values   = ["repo:${var.organization}/${var.repo_name}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${var.organization}-ci-${var.repo_name}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = local.tags
}

data "aws_iam_policy_document" "github_actions" {
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

resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-${var.repo_name}"
  description = "Grant Github Actions the ability to push to Opswerks EKS repo from ${var.repo_name}"
  policy      = data.aws_iam_policy_document.github_actions.json
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}

output "github_actions_role" {
  value = aws_iam_role.github_actions.arn
}