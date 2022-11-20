output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}


### opswerks-eks-ph-1 outputs ###
output "rds_db_endpoint" {
  value = aws_db_instance.awsospwerkseksph1db.endpoint
}

output "rds_db_name" {
  value = aws_db_instance.awsospwerkseksph1db.identifier
}

output "opswerks-eks-ph-1_assets_s3_bucket" {
  value = aws_s3_bucket.opswerks-eks-ph-1.id
}

output "opswerks-eks-ph-1_repository" {
  value = aws_ecr_repository.opswerks-eks-ph-1.registry_id
}

