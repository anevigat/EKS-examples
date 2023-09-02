module "alb_ingress" {
  source           = "./modules/eks-iam-role-with-oidc//"
  enable           = var.aws_load_balancer_controller_enabled
  cluster_name     = module.eks.cluster_id
  role_name        = "alb-ingress"
  service_accounts = ["kube-system/aws-load-balancer-controller"]
  policies         = [file("files/aws-alb/alb-iam-policy.json")]
  tags             = var.tags
}

resource "helm_release" "alb_ingress" {
  count           = var.aws_load_balancer_controller_enabled != true ? 0 : 1
  name            = "aws-load-balancer-controller"
  repository      = var.aws_load_balancer_controller.chart
  chart           = "aws-load-balancer-controller"
  namespace       = "kube-system"
  version         = var.aws_load_balancer_controller.version
  cleanup_on_fail = false
  force_update    = false
  recreate_pods   = true

  set {
    name  = "fullnameOverride"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "autoDiscoverAwsVpcID"
    value = "true"
  }

  set {
    name  = "enableReadinessProbe"
    value = "true"
  }

  set {
    name  = "enableLivenessProbe"
    value = "true"
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
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.alb_ingress.iam_role_arn
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  dynamic "set" {
    for_each = var.aws_load_balancer_controller.extra_sets != null ? var.aws_load_balancer_controller.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
