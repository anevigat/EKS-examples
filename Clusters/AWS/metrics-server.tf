# The below workaround is to solve certificate signed by unknown authority https://github.com/kubernetes-sigs/metrics-server/issues/443
resource "kubernetes_cluster_role_binding" "kubelet_api_admin" {
  count = var.metrics_server_enabled != true ? 0 : 1
  metadata {
    name = "kubelet-api-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:kubelet-api-admin"
  }

  subject {
    kind      = "User"
    name      = "kubelet-api"
    api_group = "rbac.authorization.k8s.io"
    namespace = ""
  }
}

resource "helm_release" "metrics_server" {
  count           = var.metrics_server_enabled != true ? 0 : 1
  name            = "metrics-server"
  repository      = var.metrics_server.chart
  chart           = "metrics-server"
  namespace       = "kube-system"
  version         = var.metrics_server.version
  cleanup_on_fail = false
  force_update    = false
  recreate_pods   = true

  set {
    name  = "nameOverride"
    value = "metrics-server"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "args"
    value = "{--v=2,--kubelet-preferred-address-types=InternalIP,--kubelet-insecure-tls}"
  }

  set {
    name  = "priorityClassName"
    value = "system-node-critical"
  }

  dynamic "set" {
    for_each = var.metrics_server.extra_sets != null ? var.metrics_server.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }
}
