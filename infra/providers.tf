# Most of this versions are selected to be compatible with 
# terraform-aws-modules/eks/aws module version ~> 21.0
# and AWS EKS kubernetes version 1.33 Current stable version.
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/21.8.0

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ProjectName = "TSTC01"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}

#--- Kubernetes provider (for CRDs, etc.)
provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

#--- Helm provider uses the same auth 
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
