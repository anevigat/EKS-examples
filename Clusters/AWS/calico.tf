resource "helm_release" "calico" {
  count            = var.calico_enabled != true ? 0 : 1
  name             = "calico"
  repository       = var.calico.chart
  chart            = "tigera-operator"
  namespace        = "tigera-operator"
  create_namespace = true
  version          = var.calico.version
  cleanup_on_fail  = false
  force_update     = false
  recreate_pods    = true

  set {
    name  = "nameOverride"
    value = "calico"
  }

  dynamic "set" {
    for_each = var.calico.extra_sets != null ? var.calico.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
