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


## Full configuration with network policies and ingress ##
#module "<NAMESPACE_NAME>" {
#  source = "./modules/kubernetes_config"
#  name   = "<NAMESPACE_NAME>"
##  owner  = var.owner ## Optional - Default: "Digital"
##  env    = "test" ## Optional - Default: "prod"
##  role_read_write = true ## Optional - Default: false

## Optional - Default: {} - Type: map of objects - Add as many blocks as needed
#  network_policies_ingress = {
#    <SERVICE_NAME> = {
#      label = "LABEL>",
#      label_values = ["<LABEL_VALUE>"],
#      port = <PORT>,
#      protocol = "<PROTOCOL>"
#    },
#  }
#
## Optional - Default: null - Type: map
#  ingress_ssl = {
#    enabled         = true
#    certificate_arn = "arn:aws:acm:eu-west-1:268933712607:certificate/612c14be-9692-481c-b576-2ad6260d10ba"
#    listen_ports    = [
#      { HTTPS = 443 }
#    ]
#    ssl_redirect    = "443"
#    ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
#  }
#
## Optional - Default: null - Type: list of maps - Add as many blocks as needed
#  ingress_rules = {
#    <DNS_HOST>-<ENV> = {
#      proxied = true # If true requests will be proxied through Cloudflare
#      paths   = [
#        {
#          service_name = "<SERVICE_NAME>-ENV",
#          service_port = "<SERVICE_PORT>",
#          path         = "<PATH>"
#        }
#      ]
#    }
#  }
#
## Optional - Default: null - Type: list of maps - Add as many blocks as needed
#   rate_limit_rules = [
#     {
#       url_pattern = "nexudus-listener-test..digital/api/v1/wifi",
#       threshold   = "10", # number of requests per period
#       period      = "60", # number of seconds
#       timeout     = "60"  # number of seconds
#     }
#   ]
#}