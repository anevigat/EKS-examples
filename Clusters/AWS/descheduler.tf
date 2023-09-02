# https://github.com/kubernetes-sigs/descheduler#install-using-helm
# https://github.com/kubernetes-sigs/descheduler/tree/master/charts/descheduler
resource "helm_release" "descheduler" {
  count           = var.descheduler_enabled != true ? 0 : 1
  name            = "descheduler"
  repository      = var.descheduler.chart
  chart           = "descheduler"
  namespace       = "kube-system"
  version         = var.descheduler.version
  cleanup_on_fail = false
  force_update    = false
  recreate_pods   = true

  set {
    name  = "nameOverride"
    value = "descheduler"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "podSecurityPolicy.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  values = [
    "${file("files/descheduler/values.yaml")}"
  ]

  dynamic "set" {
    for_each = var.descheduler.extra_sets != null ? var.descheduler.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
