resource "kubernetes_ingress_v1" "ingress" {
  count = var.ingress_rules != null ? 1 : 0

  metadata {
    name = "ingress"
    namespace = kubernetes_namespace.namespace.id
    annotations = {
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"    = var.ingress_ssl.enabled ? jsonencode(var.ingress_ssl.listen_ports) : null
      "alb.ingress.kubernetes.io/ssl-redirect"    = var.ingress_ssl.enabled ? var.ingress_ssl.ssl_redirect : null
      "alb.ingress.kubernetes.io/ssl-policy"      = var.ingress_ssl.enabled ? var.ingress_ssl.ssl_policy : null
      "alb.ingress.kubernetes.io/certificate-arn" = var.ingress_ssl.enabled ? var.ingress_ssl.certificate_arn : null
    }
  }

  spec {
    dynamic "rule" {
      for_each = var.ingress_rules != null ? var.ingress_rules : {}
      content {
        host = "${rule.key}.${var.dns_domain}"
        http {
          dynamic "path" {
            for_each = rule.value["paths"]
            content {
              backend {
                service {
                  name = path.value["service_name"]
                  port {
                    number = path.value["service_port"]
                  }
                }
              }

              path = path.value["path"]
            }
          }
        }
      }
    }
  }

  wait_for_load_balancer = true

}