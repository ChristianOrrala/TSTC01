# General Configuration
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "availability_zones" {
  description = "List of Availability Zones to use for the EKS control plane and node groups."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# EKS Cluster Configuration
variable "cluster_name" {
  type    = string
  default = "voting-eks"
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

# Node Group Configuration
variable "node_min" {
  type    = number
  default = 2
}

variable "node_max" {
  type    = number
  default = 4
}

variable "node_desired" {
  type    = number
  default = 2
}

# GitHub Configuration
variable "github_org" {
  type = string
}

variable "github_repo" {
  type = string
}

# ECR Configuration
variable "ecr_force_delete" {
  type    = bool
  default = true
}
