module "ebs_csi_driver" {
  source           = "./modules/eks-iam-role-with-oidc//"
  enable           = var.aws_ebs_csi_enabled
  cluster_name     = module.eks.cluster_id
  role_name        = "ebs-csi"
  service_accounts = ["kube-system/ebs-csi-controller-sa"]
  policies         = [file("files/aws-ebs-csi-driver/ebs-csi-policy.json")]
  tags             = var.tags
}

resource "helm_release" "aws_ebs_csi" {
  count           = var.aws_ebs_csi_enabled != true ? 0 : 1
  name            = "aws-ebs-csi-driver"
  repository      = var.aws_ebs_csi_driver.chart
  chart           = "aws-ebs-csi-driver"
  namespace       = "kube-system"
  version         = var.aws_ebs_csi_driver.version
  cleanup_on_fail = false
  force_update    = false
  recreate_pods   = true

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.ebs_csi_driver.iam_role_arn
  }

  dynamic "set" {
    for_each = var.aws_ebs_csi_driver.extra_sets != null ? var.aws_ebs_csi_driver.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
