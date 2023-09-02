module "main" {
  source          = "./modules/kubernetes_config"
  name            = "main"
  owner           = var.owner
  env             = "test"
  role_read_write = true

  network_policies_ingress = {
    ping = {
      label = "app",
      label_values = ["ping"],
      port = 8080,
      protocol = "TCP"
    },
    data = {
      label = "app",
      label_values = ["data"],
      port = 8080,
      protocol = "TCP"
    },
    admin = {
      label = "app",
      label_values = ["admin"],
      port = 8090,
      protocol = "TCP"
    }
  }

## Optional - Default: null - Type: list of maps
## https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/tasks/ssl_redirect/
## https://www.stacksimplify.com/aws-eks/aws-alb-ingress/learn-to-enable-ssl-on-alb-ingress-service-in-kubernetes-on-aws-eks/
  ingress_ssl = {
    enabled         = true
    certificate_arn = "arn:aws:acm:eu-west-1:ACCOUNT:certificate/CERTID"
    listen_ports    = [
      { HTTP  = 80 },
      { HTTPS = 443 },
      { HTTPS = 4443 }
    ]
    ssl_redirect    = "443"
    ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  }

  ingress_rules = {
    ping = {
      proxied = true
      paths   = [
        {
          service_name = "ping-service",
          service_port = "80",
          path         = "/ping"
        },
        {
          service_name = "data-service",
          service_port = "80",
          path         = "/data"
        }
      ]
    },
    admin = {
      proxied = false
      paths   = [
        {
          service_name = "admin-service",
          service_port = "8090",
          path         = "/admin"
        }
      ]
    }
  }

}