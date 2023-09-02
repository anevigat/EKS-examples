resource "kubernetes_namespace" "onepassword" {
  count = var.onepassword_enabled != true ? 0 : 1
  metadata {
    labels = {
      env   = var.env
      name  = "onepassword"
    }

    name = "onepassword"
  }
}

# Deny access from other namespaces - Always applied
resource "kubernetes_network_policy" "deny-from-other-ns-onepassword" {
  count = var.onepassword_enabled != true ? 0 : 1

  metadata {
    name      = "deny-from-other-ns"
    namespace = "onepassword"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "onepassword"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }

  depends_on = [kubernetes_namespace.onepassword]
}

resource "kubernetes_secret" "onepassword-token" {
  count = var.onepassword_enabled != true ? 0 : 1

  metadata {
    name      = "onepassword-token"
    namespace = "onepassword"

    labels = {
      env   = var.env
      name  = "onepassword-token"
    }
  }

  data = {
    token = sensitive("${var.onepassword_operator_token}")
  }

  depends_on = [kubernetes_namespace.onepassword]
}

resource "kubernetes_secret" "op-credentials" {
  count = var.onepassword_enabled != true ? 0 : 1

  metadata {
    name      = "op-credentials"
    namespace = "onepassword"

    labels = {
      env   = var.env
      name  = "op-credentials"
    }
  }

  data = {
    "1password-credentials.json" = sensitive("${base64encode("${var.onepassword_connect_credentials}")}")
  }

  depends_on = [kubernetes_namespace.onepassword]
}

# https://developer.1password.com/docs/connect/get-started
# https://github.com/1Password/onepassword-operator
# https://github.com/1Password/connect-helm-charts
resource "helm_release" "onepassword" {
  count            = var.onepassword_enabled != true ? 0 : 1
  name             = "onepassword"
  repository       = var.onepassword.chart
  chart            = "connect"
  namespace        = "onepassword"
  version          = var.onepassword.version
  cleanup_on_fail  = false
  force_update     = false
  recreate_pods    = true
  # create_namespace = true

  # set_sensitive {
  #   name  = "connect.credentials"
  #   value = "${file("${local_file.onepassword_connect_credentials[0].filename}")}"
  # }

  set {
    name  = "operator.create"
    value = "true"
  }

  # set_sensitive {
  #   name  = "connect.credentials"
  #   value = sensitive("${var.onepassword_operator_token}")
  # }

  depends_on = [kubernetes_namespace.onepassword,kubernetes_secret.op-credentials,kubernetes_secret.onepassword-token]
}