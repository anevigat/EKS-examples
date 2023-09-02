resource "kubernetes_secret" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent"
    namespace = "kube-system"

    labels = {
      env   = var.env
      name  = "elastic-agent"
    }
  }

  data = {
    FLEET_ENROLLMENT_TOKEN = var.elastic_agent_fleet_token
  }

}

resource "kubernetes_daemonset" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent"
    namespace = "kube-system"
    labels = {
      app = "elastic-agent"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "elastic-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "elastic-agent"
        }
      }

      spec {
        service_account_name = "elastic-agent"
        host_network         = "true"
        dns_policy           = "ClusterFirstWithHostNet"

        toleration {
          key    = "node-role.kubernetes.io/master"
          effect = "NoSchedule"
        }

        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          effect = "NoSchedule"
        }

        container {
          name  = "elastic-agent"
          image = "docker.elastic.co/beats/elastic-agent:${var.elastic_agent_version}"

          resources {
            limits = {
              cpu    = "1"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          env {
            name = "FLEET_ENROLLMENT_TOKEN"

            value_from {
              secret_key_ref {
                name = "elastic-agent"
                key  = "FLEET_ENROLLMENT_TOKEN"
              }
            }
          }

          env {
            name = "FLEET_URL"
            value = var.elastic_agent_fleet_url
          }

          env {
            name  = "FLEET_ENROLL"
            value = "1"
          }

          env {
            name = "FLEET_INSECURE"
            value = "true"
          }

          env {
            name = "NODE_NAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          security_context {
            run_as_user = "0"
          }

          volume_mount {
            name       = "proc"
            mount_path = "/hostfs/proc"
            read_only  = "true"
          }

          volume_mount {
            name       = "cgroup"
            mount_path = "/hostfs/sys/fs/cgroup"
            read_only  = "true"
          }

          volume_mount {
            name       = "varlibdockercontainers"
            mount_path = "/var/lib/docker/containers"
            read_only  = "true"
          }

          volume_mount {
            name       = "varlog"
            mount_path = "/var/log"
            read_only  = "true"
          }

          volume_mount {
            name       = "etc-full"
            mount_path = "/hostfs/etc"
            read_only  = "true"
          }

          volume_mount {
            name       = "var-lib"
            mount_path = "/hostfs/var/lib"
            read_only  = "true"
          }

          volume_mount {
            name       = "etc-mid"
            mount_path = "/etc/machine-id"
            read_only  = "true"
          }
        }

        volume {
          name = "elastic-agent"
          secret {
            secret_name = "elastic-agent"
          }
        }

        volume {
          name = "proc"
          host_path {
            path = "/proc"
          }
        }

        volume {
          name = "cgroup"
          host_path {
            path = "/sys/fs/cgroup"
          }
        }

        volume {
          name = "varlibdockercontainers"
          host_path {
            path = "/var/lib/docker/containers"
          }
        }

        volume {
          name = "varlog"
          host_path {
            path = "/var/log"
          }
        }

        volume {
          name = "etc-full"
          host_path {
            path = "/etc"
          }
        }

        volume {
          name = "var-lib"
          host_path {
            path = "/var/lib"
          }
        }

        volume {
          name = "etc-mid"
          host_path {
            path = "/etc/machine-id"
            type = "File"
          }
        }
      }
    }
  }

}

resource "kubernetes_service_account" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent"
    namespace = "kube-system"

    labels = {
      env     = var.env
      name    = "elastic-agent"
      k8s-app = "elastic-agent"
    }
  }

}

resource "kubernetes_role" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent"
    namespace = "kube-system"
    labels = {
      env     = var.env
      name    = "elastic-agent"
      k8s-app = "elastic-agent"
    }
  }

  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["get", "create", "update"]
  }

}

resource "kubernetes_role" "elastic-agent-kubeadm-config" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent-kubeadm-config"
    namespace = "kube-system"
    labels = {
      env     = var.env
      name    = "elastic-agent-kubeadm-config"
      k8s-app = "elastic-agent"
    }
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubeadm-config"]
    verbs          = ["get"]
  }

}

resource "kubernetes_role_binding" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent"
    namespace = "kube-system"
    labels = {
      env     = var.env
      name    = "elastic-agent"
      k8s-app = "elastic-agent"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "elastic-agent"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "elastic-agent"
    namespace = "kube-system"
  }

}

resource "kubernetes_role_binding" "elastic-agent-kubeadm-config" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name      = "elastic-agent-kubeadm-config"
    namespace = "kube-system"
    labels = {
      env     = var.env
      name    = "elastic-agent-kubeadm-config"
      k8s-app = "elastic-agent"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "elastic-agent-kubeadm-config"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "elastic-agent"
    namespace = "kube-system"
  }

}

resource "kubernetes_cluster_role" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name = "elastic-agent"
    labels = {
      #owner   = var.owner
      env     = var.env
      name    = "elastic-agent"
      k8s-app = "elastic-agent"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "namespaces", "events", "pods", "services", "configmaps", "serviceaccounts", "persistentvolumes", "persistentvolumeclaims"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["elastic-agent"]
    verbs          = ["get"]
  }

  rule {
    api_groups = ["extensions"]
    resources  = ["replicasets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments", "replicasets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes/stats"]
    verbs      = ["get"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterrolebindings", "clusterroles", "rolebindings", "roles"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["policy"]
    resources  = ["podsecuritypolicies"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "elastic-agent" {
  count = var.elastic_agent_enabled != true ? 0 : 1

  metadata {
    name = "elastic-agent"
    labels = {
      #owner   = var.owner
      env     = var.env
      name    = "elastic-agent"
      k8s-app = "elastic-agent"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "elastic-agent"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "elastic-agent"
    namespace = "kube-system"
  }

}