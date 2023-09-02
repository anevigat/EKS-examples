# Read only resources
resource "kubernetes_role" "read_only" {
  count = var.role_read_write != true ? 1 : 0

  metadata {
    name = "read_only"
    namespace = kubernetes_namespace.namespace.id
    labels = {
      owner = var.owner
      env   = var.env
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
    verbs      = ["get", "list", "watch", "describe", "delete"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch", "describe"]
  }
}

resource "kubernetes_role_binding" "read_only" {
  count = var.role_read_write != true ? 1 : 0

  metadata {
    name      = "read_only"
    namespace = kubernetes_namespace.namespace.id
    labels = {
      owner = var.owner
      env   = var.env
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "read_only"
  }
  subject {
    kind      = "User"
    name      = var.user
    api_group = "rbac.authorization.k8s.io"
  }
}

# Read-write resources
resource "kubernetes_role" "read_write" {
  count = var.role_read_write != true ? 0 : 1

  metadata {
    name = "read_write"
    namespace = kubernetes_namespace.namespace.id
    labels = {
      owner = var.owner
      env   = var.env
    }
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["configmaps", "cronjobs", "deployments", "deployments/scale", "events", "jobs", "pods", "pods/log", "pods/portforward", "pods/exec"]
    verbs      = ["get", "list", "watch", "describe", "delete", "patch", "update", "create"]
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "services", "endpoints"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch", "describe"]
  }
}

resource "kubernetes_role_binding" "read_write" {
  count = var.role_read_write != true ? 0 : 1

  metadata {
    name      = "read_write"
    namespace = kubernetes_namespace.namespace.id
    labels = {
      owner = var.owner
      env   = var.env
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "read_write"
  }
  subject {
    kind      = "User"
    name      = var.user
    api_group = "rbac.authorization.k8s.io"
  }
}