resource "helm_release" "kube_state_metrics_grafana" {
  count         = var.grafana_agent_enabled != true ? 0 : 1
  name          = "ksm"
  repository    = var.kube_state_metrics.chart
  chart         = "kube-state-metrics"
  namespace     = "grafana-agent"
  version       = var.kube_state_metrics.version
  force_update  = false
  recreate_pods = true

  set {
    name  = "nameOverride"
    value = "kube-state-metrics"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  dynamic "set" {
    for_each = var.kube_state_metrics.extra_sets != null ? var.kube_state_metrics.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}