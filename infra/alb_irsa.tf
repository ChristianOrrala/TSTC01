data "http" "alb_controller_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.0/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller" {
  name   = "${var.cluster_name}-AWSLoadBalancerControllerIAMPolicy"
  policy = data.http.alb_controller_policy.response_body
}

# IRSA role trust policy for the aws-load-balancer-controller service account
data "aws_iam_policy_document" "alb_irsa_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
    # SA in kube-system
    condition {
      test     = "StringLike"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "alb_irsa" {
  name               = "${var.cluster_name}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_irsa_trust.json
}

resource "aws_iam_role_policy_attachment" "alb_irsa_attach" {
  role       = aws_iam_role.alb_irsa.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

resource "helm_release" "aws_load_balancer_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = "1.13.0"
  namespace        = "kube-system"
  create_namespace = false

  set = [
    {
      name  = "region"
      value = data.aws_region.current.name
    },
    {
      name  = "vpcId"
      value = data.aws_vpc.default.id
    },
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.alb_irsa.arn
    }
  ]

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.alb_irsa_attach
  ]
}

locals {
  elb_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_ec2_tag" "subnet_elb_tags" {
  for_each    = toset(data.aws_subnets.default.ids)
  resource_id = each.value
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "subnet_cluster_tags" {
  for_each    = toset(data.aws_subnets.default.ids)
  resource_id = each.value
  key         = "kubernetes.io/cluster/${var.cluster_name}"
  value       = "shared"
}

#--- EKS connection data (from your created cluster)
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}
