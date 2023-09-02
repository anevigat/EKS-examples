data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    sid    = "clusterAutoscalerAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "clusterAutoscalerOwn"
    effect = "Allow"

    actions = [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeInstanceTypes",
        "eks:DescribeNodegroup"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${module.eks.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}

module "cluster_autoscaler" {
  source           = "./modules/eks-iam-role-with-oidc//"
  enable           = var.cluster_autoscaler_enabled
  cluster_name     = module.eks.cluster_id
  role_name        = "cluster-autoscaler"
  service_accounts = ["kube-system/cluster-autoscaler"]
  policies         = [data.aws_iam_policy_document.cluster_autoscaler.json]
  tags             = var.tags
}

resource "helm_release" "cluster_autoscaler" {
  count           = var.cluster_autoscaler_enabled != true ? 0 : 1
  name            = "cluster-autoscaler"
  repository      = var.cluster_autoscaler.chart
  chart           = "cluster-autoscaler"
  namespace       = "kube-system"
  version         = var.cluster_autoscaler.version
  cleanup_on_fail = false
  force_update    = false
  recreate_pods   = true
  max_history     = 5

  set {
    name  = "fullnameOverride"
    value = "cluster-autoscaler"
  }

  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  set {
    name  = "extraArgs.balance-similar-node-groups"
    value = "true"
  }

  set {
    name  = "extraArgs.expander"
    value = "least-waste"
  }

  set {
    name  = "extraArgs.skip-nodes-with-system-pods"
    value = "false"
  }

  set {
    name  = "extraArgs.skip-nodes-with-local-storage"
    value = "false"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler.iam_role_arn
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "autoDiscovery.tags"
    value = "kubernetes.io/cluster/${module.eks.cluster_id}"
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  dynamic "set" {
    for_each = var.cluster_autoscaler.extra_sets != null ? var.cluster_autoscaler.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
