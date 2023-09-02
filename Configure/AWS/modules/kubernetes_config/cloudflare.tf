data "cloudflare_zone" "digital" {
  name = var.dns_domain
}

resource "cloudflare_record" "cname" {
  for_each = var.ingress_rules != null ? var.ingress_rules : {}

  zone_id         = data.cloudflare_zone.digital.id
  name            = each.key
  value           = kubernetes_ingress_v1.ingress[0].status[0].load_balancer[0].ingress[0].hostname
  proxied         = each.value["proxied"]
  type            = "CNAME"
  ttl             = each.value["proxied"] ? 1 : 60
  allow_overwrite = true

}

resource "cloudflare_record" "cname_nlb" {
  count   = var.nlb != null ? 1 : 0

  zone_id = data.cloudflare_zone.digital.id
  name    = var.nlb.name
  value   = kubernetes_service.nlb[0].status[0].load_balancer[0].ingress[0].hostname
  proxied = var.nlb.proxied
  type    = "CNAME"
  ttl     = var.nlb.proxied ? 1 : 60
  allow_overwrite = true

}

resource "cloudflare_rate_limit" "rate_limit" {
  for_each = var.rate_limit_rules == null ? {} : {
    for url_pattern in var.rate_limit_rules: url_pattern.url_pattern => url_pattern
  }

  zone_id = data.cloudflare_zone.digital.id
  threshold = each.value.threshold
  period = each.value.period
  match {
    request {
      url_pattern = "*${each.value.url_pattern}*"
    }
  }
  action {
    mode = "ban"
    timeout = each.value.timeout
  }
}