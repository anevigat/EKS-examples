terraform {
  required_providers {
    # https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.15.0"
    }
  }
}