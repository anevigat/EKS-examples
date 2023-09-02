resource "kubernetes_namespace" "argowf" {
  count = var.argowf_enabled != true ? 0 : 1
  metadata {
    labels = {
      env   = var.env
      name  = "argo-wf"
    }

    name = "argowf"
  }
}

# Deny access from other namespaces - Always applied
resource "kubernetes_network_policy" "deny-from-other-ns-argowf" {
  count = var.argowf_enabled != true ? 0 : 1

  metadata {
    name      = "deny-from-other-ns"
    namespace = kubernetes_namespace.argowf[0].id
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argowf"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }

  depends_on = [kubernetes_namespace.argowf]
}

# https://github.com/argoproj/argo-helm/tree/main/charts/argo-workflows
resource "helm_release" "argowf" {
  count           = var.argowf_enabled != true ? 0 : 1
  name            = "argowf"
  repository      = var.argowf.chart
  chart           = "argo-workflows"
  namespace       = kubernetes_namespace.argowf[0].id
  version         = var.argowf.version
  cleanup_on_fail = false
  force_update    = false
  recreate_pods   = true

  set {
    name  = "nameOverride"
    value = "argowf"
  }

  dynamic "set" {
    for_each = var.argowf.extra_sets != null ? var.argowf.extra_sets : {}
    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [kubernetes_namespace.argowf]
}

# Cluster Role and CRB for read-only user
resource "kubernetes_role" "argowf-ro" {
  count = var.argowf_enabled != true ? 0 : 1

  metadata {
    name = "argowf-ro"
    namespace = kubernetes_namespace.argowf[0].id
    labels = {
      env     = var.env
      name    = "argowf-ro"
      k8s-app = "argowf-ro"
    }
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["configmaps", "cronjobs", "deployments", "deployments", "events", "jobs", "pods/log", "secrets", "services", "endpoints"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["get", "list", "watch", "describe", "delete", "patch", "update", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch", "describe"]
  }

}

resource "kubernetes_role_binding" "argowf-ro" {
  count = var.argowf_enabled != true ? 0 : 1

  metadata {
    name = "argowf-ro"
    namespace = kubernetes_namespace.argowf[0].id
    labels = {
      env     = var.env
      name    = "argowf-ro"
      k8s-app = "argowf-ro"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "argowf-ro"
  }
  subject {
    kind      = "User"
    name      = "dev-user"
    namespace = "default"
  }

}

## Workflows runner
resource "kubernetes_namespace" "argowf-runner" {
  count = var.argowf_enabled != true ? 0 : 1
  metadata {
    labels = {
      env   = var.env
      name  = "argowf-runner"
    }

    name = "argowf-runner"
  }
}

# Workflows Service Account
resource "kubernetes_service_account" "argowf-runner" {
  count = var.argowf_enabled != false ? 1 : 0

  metadata {
    name      = "argowf-runner"
    namespace = kubernetes_namespace.argowf-runner[0].id

    labels = {
      env     = var.env
      name    = "argowf-runner"
      k8s-app = "argowf-runner"
    }
  }

}

# Workflows Role
resource "kubernetes_cluster_role" "argowf-runner" {
  count = var.argowf_enabled != false ? 1 : 0

  metadata {
    name = "argowf-runner"
    labels = {
      env   = var.env
    }
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "deployments/scale"]
    verbs      = ["get", "list", "watch", "patch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "delete"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get"]
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["workflowtasksets"]
    verbs      = ["list", "watch"]
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["workflowtasksets/status"]
    verbs      = ["patch"]
  }

}

# Workflows Role Binding
resource "kubernetes_cluster_role_binding" "argowf-runner" {
  count = var.argowf_enabled != false ? 1 : 0

  metadata {
    name      = "argowf-runner"
    labels = {
      env   = var.env
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argowf-runner"
  }
  subject {
    kind      = "ServiceAccount"
    namespace = kubernetes_namespace.argowf-runner[0].id
    name      = "argowf-runner"
  }
}

# Secret with token
resource "kubernetes_secret" "argowf-runner" {
  count = var.argowf_enabled != false ? 1 : 0

  metadata {
    name      = "argowf-runner.service-account-token"
    namespace = kubernetes_namespace.argowf-runner[0].id
    labels = {
      env   = var.env
      name  = "argowf-runner"
    }

    annotations = {
      "kubernetes.io/service-account.name" = "argowf-runner"
    }

  }

  type = "kubernetes.io/service-account-token"

}

# Role and RB for dev user to handle workflows
resource "kubernetes_role" "argowf-runner-ro" {
  count = var.argowf_enabled != true ? 0 : 1

  metadata {
    name = "argowf-runner-ro"
    namespace = kubernetes_namespace.argowf-runner[0].id
    labels = {
      env     = var.env
      name    = "argowf-runner-ro"
      k8s-app = "argowf-runner-ro"
    }
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["configmaps", "cronjobs", "deployments", "deployments", "events", "jobs", "pods/log", "secrets", "services", "endpoints"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["get", "list", "watch", "describe", "delete", "patch", "update", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch", "describe"]
  }

}

resource "kubernetes_role_binding" "argowf-runner-ro" {
  count = var.argowf_enabled != true ? 0 : 1

  metadata {
    name = "argowf-runner-ro"
    namespace = kubernetes_namespace.argowf-runner[0].id
    labels = {
      env     = var.env
      name    = "argowf-runner-ro"
      k8s-app = "argowf-runner-ro"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "argowf-runner-ro"
  }
  subject {
    kind      = "User"
    name      = "dev-user"
    namespace = "default"
  }

}

resource "kubernetes_role_binding" "argowf-dev-access" {
  count = var.argowf_enabled != true ? 0 : 1

  metadata {
    name = "argowf-dev-access"
    namespace = kubernetes_namespace.argowf-runner[0].id
    labels = {
      env     = var.env
      name    = "argowf-dev-access"
      k8s-app = "argowf-dev-access"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "argowf-edit"
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = "dev-user"
  }

}