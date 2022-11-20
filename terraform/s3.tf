### opswerks-eks-ph-1 S3 details ###
resource "aws_s3_bucket" "opswerks-eks-ph-1" {
  bucket = "opswerks-eks-ph-1-files-${var.environment}"

  tags = merge(
    {Name = "Opswerks EKS File Store"},
    {Project = "Default EKS Cluster"}, 
    local.tags
  )
}

resource "aws_s3_bucket_acl" "opswerks-eks-ph-1-acl" {
  bucket = aws_s3_bucket.opswerks-eks-ph-1.id
  acl    = "private"
}

data "aws_iam_policy_document" "opswerks_eks_ph_1_s3_policy" {
  statement {
    sid       = "AllowS3"
    effect    = "Allow"
    resources = [
      "${aws_s3_bucket.opswerks-eks-ph-1.arn}/*",
      aws_s3_bucket.opswerks-eks-ph-1.arn
    ]
    actions = ["s3:GetObject","s3:GetObjectVersion", "s3:PutObject", "s3:DeleteObject"]
  }
}

resource "aws_iam_policy" "opswerks-eks-ph-1_files_bucket" {
  name = "opswerks-eks-ph-1-prod-files-policy"
  policy = data.aws_iam_policy_document.opswerks_eks_ph_1_s3_policy.json
}