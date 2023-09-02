terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "4.14.0"
    }

    # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }

    # https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "3.15.0"
    }
  }

  # https://github.com/hashicorp/terraform/blob/v1.0.9/CHANGELOG.md
  required_version = "1.3.0"
}

terraform {
  # https://www.terraform.io/docs/language/settings/backends/s3.html
  backend "s3" {
    bucket = "digital-terraform-states"
    region = "eu-west-2"
  }
}

# AWS provider
provider "aws" {
  region = var.region
}

# Kubernetes provider
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

