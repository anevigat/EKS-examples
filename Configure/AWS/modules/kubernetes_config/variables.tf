variable "owner" {
  type    = string
  default = "owner"
}

variable "env" {
  type    = string
  default = "test"
}

# Kubernetes Cluster Name
variable "name" {
  type = string
}

# RBAC
variable "role_read_write" {
  type    = bool
  default = false
}

variable "user" {
  type    = string
  default = "dev-user"
}

# Network Policies
variable "np_deny-to-nodes" {
  type    = bool
  default = true
}

variable "np_deny-from-other-ns" {
  type    = bool
  default = true
}

variable "network_policies_ingress" {
  type = map(object({
    label        = string
    label_values = set(string)
    port         = string
    protocol     = string
  }))
  default = {}
}

variable "dns_domain" {
  type    = string
  default = "domain.com"
}

# Ingress SSL
variable "ingress_ssl" {
  type = object({
    enabled         = bool
    certificate_arn = string
    listen_ports    = list(map(any))
    ssl_redirect    = string
    ssl_policy      = string
  })
  default = {
    enabled         = false
    certificate_arn = null
    listen_ports    = [
      { HTTP  = 80 },
      { HTTPS = 443}
    ]
    ssl_redirect    = null
    ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  }
}

# Ingress Rules
variable "ingress_rules" {
  type    = map(object({
    proxied = bool
    paths   = list(map(string))
  }))
  default = null
}

# NLB SSL
variable "nlb_ssl" {
  type = object({
    enabled         = bool
    certificate_arn = string
    ssl_ports       = string
    ssl_attributes  = string
    ssl_policy      = string
  })
  default = {
    enabled         = false
    certificate_arn = null
    ssl_ports       = null
    ssl_attributes  = null
    ssl_policy      = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  }
}

# NLB Ports
variable "nlb" {
  type           = object({
    name    = string
    app     = string
    proxied = bool
    ports   = list(map(string))
  })
  default = null
}

# NLB Readiness gate
variable "readiness_gate" {
  type    = bool
  default = false
}

# Rate limiting Rules
variable "rate_limit_rules" {
  type    = list(map(string))
  default = null
}

# Argo Workflows
variable "argowf_enabled" {
  type    = bool
  default = false
}