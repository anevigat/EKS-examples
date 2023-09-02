resource "kubernetes_service" "nlb" {
  count = var.nlb != null ? 1 : 0

  metadata {
    name = "nlb"
    namespace = kubernetes_namespace.namespace.id
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                    = "external"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"                  = "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"         = "ip"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = var.nlb_ssl.enabled ? var.nlb_ssl.ssl_ports : null
      "service.beta.kubernetes.io/aws-load-balancer-target-group-attributes" = var.nlb_ssl.enabled ? var.nlb_ssl.ssl_attributes : null
      "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy"  = var.nlb_ssl.enabled ? var.nlb_ssl.ssl_policy : null
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = var.nlb_ssl.enabled ? var.nlb_ssl.certificate_arn : null
    }
  }

  spec {
    selector = {
      app = var.nlb.app
    }

    session_affinity    = "ClientIP"
    load_balancer_class = "service.k8s.aws/nlb"

    dynamic "port" {
      for_each = var.nlb.ports
      content {
        name        = port.value["name"]
        protocol    = port.value["protocol"]
        port        = port.value["port"]
        target_port = port.value["target_port"]
      }
    }

    type = "LoadBalancer"
  }

  wait_for_load_balancer = true

}