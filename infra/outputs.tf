#############################################
# Core cluster info
#############################################

output "region" {
  description = "AWS region used by this deployment."
  value       = data.aws_region.current.name
}

output "account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca" {
  description = "EKS Cluster CA (base64)."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "eks_cluster_security_group_id" {
  description = "Cluster security group ID created by the EKS module."
  value       = module.eks.cluster_security_group_id
}

output "eks_availability_zones" {
  description = "Availability Zones used for the EKS control plane and node groups."
  value       = var.availability_zones
}

#############################################
# Networking (default VPC/subnets as used)
#############################################

output "vpc_id" {
  description = "VPC ID used by the cluster (default VPC in this setup)."
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "Subnet IDs used by the EKS cluster."
  value       = data.aws_subnets.default.ids
}

#############################################
# OIDC / IRSA
#############################################

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA."
  value       = module.eks.oidc_provider
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "github_actions_role_arn" {
  description = "IAM Role ARN assumed by GitHub Actions via OIDC."
  value       = aws_iam_role.github_actions.arn
}

#############################################
# ECR repositories
#############################################

output "ecr_registry" {
  description = "Base ECR registry URL for this account/region."
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com"
}

output "ecr_vote_repo_url" {
  description = "ECR repository URL for the 'vote' image."
  value       = aws_ecr_repository.vote.repository_url
}

output "ecr_result_repo_url" {
  description = "ECR repository URL for the 'result' image."
  value       = aws_ecr_repository.result.repository_url
}

output "ecr_worker_repo_url" {
  description = "ECR repository URL for the 'worker' image."
  value       = aws_ecr_repository.worker.repository_url
}

#############################################
# Convenience commands (copy/paste ready)
#############################################

output "cmd_update_kubeconfig" {
  description = "Command to configure kubectl against this cluster."
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${data.aws_region.current.name}"
}

output "cmd_helm_deploy" {
  description = "Command to deploy/upgrade the Helm release with correct ECR registry."
  value = join(" && ", [
    "REG=$(aws sts get-caller-identity --query 'Account' --output text).dkr.ecr.${data.aws_region.current.name}.amazonaws.com",
    "helm dependency update ../helm/voting-app",
    "helm upgrade --install voting ../helm/voting-app --set imageRegistry=$REG"
  ])
}
