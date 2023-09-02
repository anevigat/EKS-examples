resource "kubernetes_namespace" "grafana-agent" {
  count = var.grafana_agent_enabled == true || var.grafana_loki_enabled == true ? 1 : 0
  metadata {
    labels = {
      env   = var.env
      name  = "grafana-agent"
    }

    name = "grafana-agent"
  }
}

# Deny access from other namespaces - Always applied
resource "kubernetes_network_policy" "deny-from-other-ns-grafana" {
  count = var.grafana_agent_enabled == true || var.grafana_loki_enabled == true ? 1 : 0

  metadata {
    name      = "deny-from-other-ns"
    namespace = "grafana-agent"
  }

  spec {
    pod_selector {
    }

    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "grafana-agent"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }

  depends_on = [kubernetes_namespace.grafana-agent]
}

data "template_file" "grafana_yaml" {
  template = "${file("files/grafana-agent/agent.tpl")}"
  vars = {
    GRAFANA_HOST      = "${var.grafana_agent_host}"
    GRAFANA_PASSWORD  = sensitive("${var.grafana_agent_password}")
    GRAFANA_USER      = "${var.grafana_agent_username}"
    GRAFANA_LOKI_USER = "${var.grafana_loki_username}"
    GRAFANA_LOKI_HOST = "${var.grafana_loki_host}"
    CLUSTER           = "${var.region}-${var.cluster_name}"
  }
}

resource "kubernetes_config_map" "grafana-agent" {
  count = var.grafana_agent_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-agent"
    namespace = "grafana-agent"

    labels = {
      env     = var.env
      name    = "grafana-agent"
      k8s-app = "grafana-agent"
    }
  }

  data = {
    "agent.yaml" = data.template_file.grafana_yaml.rendered
  }

  depends_on = [kubernetes_namespace.grafana-agent]
}

data "template_file" "grafana_loki_yaml" {
  template = "${file("files/grafana-agent/agent-loki.tpl")}"
  vars = {
    GRAFANA_HOST      = "${var.grafana_agent_host}"
    GRAFANA_PASSWORD  = sensitive("${var.grafana_agent_password}")
    GRAFANA_USER      = "${var.grafana_agent_username}"
    GRAFANA_LOKI_USER = "${var.grafana_loki_username}"
    GRAFANA_LOKI_HOST = "${var.grafana_loki_host}"
    CLUSTER           = "${var.region}-${var.cluster_name}"
  }
}

resource "kubernetes_config_map" "grafana-loki" {
  count = var.grafana_loki_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-loki"
    namespace = "grafana-agent"

    labels = {
      env     = var.env
      name    = "grafana-loki"
      k8s-app = "grafana-agent"
    }
  }

  data = {
    "agent.yaml" = data.template_file.grafana_loki_yaml.rendered
  }

  depends_on = [kubernetes_namespace.grafana-agent]
}

resource "kubernetes_service" "example" {
  count = var.grafana_agent_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-agent"
    namespace = "grafana-agent"
    labels = {
      app = "grafana-agent"
    }
  }

  spec {
    selector = {
      app = "grafana-agent"
    }

    session_affinity = "ClientIP"
    cluster_ip       = "None"

    port {
      name        = "grafana-agent-http-metrics"
      port        = 80
      target_port = 80
    }

  }

  depends_on = [kubernetes_namespace.grafana-agent]
}

resource "kubernetes_stateful_set" "grafana-agent" {
  count = var.grafana_agent_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-agent"
    namespace = "grafana-agent"
    labels = {
      app = "grafana-agent"
    }
  }

  spec {
    replicas     = 1
    service_name = "grafana-agent"

    selector {
      match_labels = {
        app = "grafana-agent"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana-agent"
        }
      }

      spec {
        service_account_name = "grafana-agent"
        # host_network         = "true"
        # dns_policy           = "ClusterFirstWithHostNet"

        container {
          image   = "grafana/agent:${var.grafana_agent_version}"
          name    = "grafana-agent"
          args    = ["-config.file=/etc/agent/agent.yaml", "-enable-features=integrations-next", "-server.http.address=0.0.0.0:80", "/bin/agent"]

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

          port {
            container_port = 80
            name           = "http-metrics"
            protocol       = "TCP"
          }

          env {
            name = "HOSTNAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name       = "grafana-agent"
            mount_path = "/etc/agent"
            read_only  = "true"
          }

        }

        volume {
          name = "grafana-agent"
          config_map {
            default_mode = "0640"
            name         = "grafana-agent"
          }
        }

      }
    }
  }

  depends_on = [kubernetes_namespace.grafana-agent,kubernetes_config_map.grafana-agent,kubernetes_service_account.grafana-agent]
}

resource "kubernetes_daemonset" "grafana-loki" {
  count = var.grafana_loki_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-loki"
    namespace = "grafana-agent"
    labels = {
      app = "grafana-agent"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "grafana-loki"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana-loki"
        }
      }

      spec {
        service_account_name = "grafana-loki"
        host_network         = "true"
        dns_policy           = "ClusterFirstWithHostNet"

        container {
          image   = "grafana/agent:${var.grafana_agent_version}"
          name    = "grafana-loki"
          args    = ["-config.file=/etc/agent/agent.yaml", "-server.http.address=0.0.0.0:80", "/bin/agent"]

          port {
            container_port = 80
          }

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
            name = "HOSTNAME"

            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }

          volume_mount {
            name       = "grafana-loki"
            mount_path = "/etc/agent"
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

        }

        volume {
          name = "grafana-loki"
          config_map {
            default_mode = "0640"
            name         = "grafana-loki"
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

      }
    }
  }

  depends_on = [kubernetes_namespace.grafana-agent,kubernetes_config_map.grafana-loki,kubernetes_service_account.grafana-loki]
}

resource "kubernetes_service_account" "grafana-agent" {
  count = var.grafana_agent_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-agent"
    namespace = "grafana-agent"

    labels = {
      env     = var.env
      name    = "grafana-agent"
      k8s-app = "grafana-agent"
    }
  }

  depends_on = [kubernetes_namespace.grafana-agent]
}

resource "kubernetes_cluster_role" "grafana-agent" {
  count = var.grafana_agent_enabled != true ? 0 : 1

  metadata {
    name = "grafana-agent"
    labels = {
      env     = var.env
      name    = "grafana-agent"
      k8s-app = "grafana-agent"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "endpoints", "pods", "services","events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }

}

resource "kubernetes_cluster_role_binding" "grafana-agent" {
  count = var.grafana_agent_enabled != true ? 0 : 1

  metadata {
    name = "grafana-agent"
    labels = {
      env     = var.env
      name    = "grafana-agent"
      k8s-app = "grafana-agent"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "grafana-agent"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "grafana-agent"
    namespace = "grafana-agent"
  }

  depends_on = [kubernetes_cluster_role.grafana-agent,kubernetes_service_account.grafana-agent]
}

resource "kubernetes_service_account" "grafana-loki" {
  count = var.grafana_loki_enabled != true ? 0 : 1

  metadata {
    name      = "grafana-loki"
    namespace = "grafana-agent"

    labels = {
      env     = var.env
      name    = "grafana-loki"
      k8s-app = "grafana-agent"
    }
  }

  depends_on = [kubernetes_namespace.grafana-agent]
}

resource "kubernetes_cluster_role" "grafana-loki" {
  count = var.grafana_loki_enabled != true ? 0 : 1

  metadata {
    name = "grafana-loki"
    labels = {
      env     = var.env
      name    = "grafana-loki"
      k8s-app = "grafana-agent"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "endpoints", "pods", "services", "events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }

}

resource "kubernetes_cluster_role_binding" "grafana-loki" {
  count = var.grafana_loki_enabled != true ? 0 : 1

  metadata {
    name = "grafana-loki"
    labels = {
      env     = var.env
      name    = "grafana-loki"
      k8s-app = "grafana-agent"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "grafana-loki"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "grafana-loki"
    namespace = "grafana-agent"
  }

  depends_on = [kubernetes_cluster_role.grafana-loki,kubernetes_service_account.grafana-loki]
}