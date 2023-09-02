# Deny access to worker nodes and system pods - Always applied
resource "kubernetes_network_policy" "deny-to-nodes" {
  count = var.np_deny-to-nodes != false ? 1 : 0

  metadata {
    name      = "deny-to-nodes"
    namespace = kubernetes_namespace.namespace.id
  }

  spec {
    pod_selector {
    }

    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
          except = [
            "10.0.0.0/16"
          ]
        }
      }
    }

    policy_types = ["Egress"]
  }
}

# Deny access from other namespaces - Always applied
resource "kubernetes_network_policy" "deny-from-other-ns" {
  count = var.np_deny-from-other-ns != false ? 1 : 0

  metadata {
    name      = "deny-from-other-ns"
    namespace = kubernetes_namespace.namespace.id
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = kubernetes_namespace.namespace.id
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}


# Allow from argowf-runnes namespace if enabled
resource "kubernetes_network_policy" "allow-from-argowf" {
  count = var.argowf_enabled != false ? 1 : 0

  metadata {
    name      = "allow-from-argowf"
    namespace = kubernetes_namespace.namespace.id
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "argowf-runner"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}


# Optional ingress network policies
resource "kubernetes_network_policy" "ingress_policies" {
  for_each = var.network_policies_ingress

  metadata {
    name      = each.key
    namespace = kubernetes_namespace.namespace.id
  }

  spec {
    pod_selector {
      match_expressions {
        key      = each.value.label
        operator = "In"
        values   = each.value.label_values
      }
    }

    ingress {
      ports {
        port     = each.value.port
        protocol = each.value.protocol
      }
    }

    policy_types = ["Ingress"]
  }
}