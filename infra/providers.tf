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
      version = "~> 2.13"
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
