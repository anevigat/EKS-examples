## Minimal configuration ##
#module "<NAMESPACE_NAME>" {
#  source = "./modules/kubernetes_config"
#  name   = "<NAMESPACE_NAME>"
#}


## Standard configuration ##
#module "<NAMESPACE_NAME>" {
#  source = "./modules/kubernetes_config"
#  name   = "<NAMESPACE_NAME>"
##  owner  = var.owner ## Optional - Default: "Digital"
##  env    = "test" ## Optional - Default: "prod"
##  role_read_write = true ## Optional - Default: false
#}


## Full configuration with network policies, ingress and Istio ##
#module "<NAMESPACE_NAME>" {
#  source = "./modules/kubernetes_config"
#  name   = "<NAMESPACE_NAME>"
##  owner  = var.owner ## Optional - Default: "Digital"
##  env    = "test" ## Optional - Default: "prod"
##  role_read_write = true ## Optional - Default: false

## Network Policies
## Optional - Default: {} - Type: map of objects - Add as many blocks as needed
#  network_policies_ingress = {
#    <SERVICE_NAME> = {
#      label = "LABEL>",
#      label_values = ["<LABEL_VALUE>"],
#      port = <PORT>,
#      protocol = "<PROTOCOL>"
#    },
#  }

## Enable Ingress
## Optional - Default: null - Type: list of maps
## https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/tasks/ssl_redirect/
## https://www.stacksimplify.com/aws-eks/aws-alb-ingress/learn-to-enable-ssl-on-alb-ingress-service-in-kubernetes-on-aws-eks/
#  ingress_ssl = {
#    enabled         = true
#    certificate_arn = "arn:aws:acm:eu-west-1:268933712607:certificate/f167404b-9000-45cb-9b9d-5fd9514fb77f"
#    listen_ports    = [
#      { HTTP  = 80 },
#      { HTTPS = 443 },
#      { HTTPS = 4443 }
#    ]
#    ssl_redirect    = "443"
#    ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
#  }

## Add Ingress rules
## Optional - Default: null - Type: list of maps - Add as many blocks as needed
#  ingress_rules = {
#    <DOMAIN_NAME> = {
#      proxied = false/true
#      paths   = [
#        {
#          service_name = "<SERVICE_NAME>",
#          service_port = "<SERVICE_PORT>",
#          path         = "<PATH>"
#        }
#      ]
#    }
#  }
#}

## Istio External services
## Optional - Default: null - Type: list of maps - Add as many blocks as needed
#  external_services = {
#    <SERVICE_NAME> = {
#      host = "www.google.es"
#      protocol = "https"
#      port = 443
#    }
#  }
#}