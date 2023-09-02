resource "kubernetes_cluster_role" "default-devs" {

  metadata {
    name = "default-devs"
    labels = {
      env     = var.env
      name    = "default-devs"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods"]
    verbs      = ["get", "list", "watch"]
  }

}

resource "kubernetes_cluster_role_binding" "default-devs" {

  metadata {
    name = "default-devs"
    labels = {
      env     = var.env
      name    = "default-devs"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "default-devs"
  }
  subject {
    kind      = "User"
    name      = "dev-user"
  }

  depends_on = [kubernetes_cluster_role.default-devs]
}