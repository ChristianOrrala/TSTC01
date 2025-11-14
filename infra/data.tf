#############################################
# AWS Account and Region Data Sources
#############################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

#############################################
# VPC and Networking Data Sources
#############################################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = var.availability_zones
  }
}

#############################################
# EKS Cluster Data Sources
#############################################

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

#############################################
# EBS CSI Driver Addon Version
#############################################

data "aws_eks_addon_version" "ebs" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = module.eks.cluster_version
  most_recent        = true
}

#############################################
# ALB Controller IAM Policy
#############################################

data "http" "alb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.0/docs/install/iam_policy.json"
}
