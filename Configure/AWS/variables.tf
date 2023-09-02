variable "owner" {
  type    = string
  default = "owner"
}

# AWS Region
variable "region" {
  type = string
}

# Kubernetes Cluster Name
variable "cluster_name" {
  type = string
}

# Cloudflare API TOKEN
variable "cloudflare_api_token" {
  type = string
}