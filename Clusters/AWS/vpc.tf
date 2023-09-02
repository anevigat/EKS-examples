# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/3.10.0
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.0"

  name                  = var.cluster_name
  cidr                  = "10.0.0.0/16"
  secondary_cidr_blocks = ["100.64.0.0/16"]
  azs                   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets       = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22", "100.64.0.0/18", "100.64.64.0/18", "100.64.128.0/18"]
  public_subnets        = ["10.0.100.0/22", "10.0.104.0/22", "10.0.108.0/22"]
  enable_nat_gateway    = true
  single_nat_gateway    = true
  enable_dns_hostnames  = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Owner"                                     = var.owner
    "Env"                                       = var.env
    "EKS"                                       = var.cluster_name
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    "Owner"                                     = var.owner
    "Env"                                       = var.env
    "EKS"                                       = var.cluster_name
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    "Owner"                                     = var.owner
    "Env"                                       = var.env
    "EKS"                                       = var.cluster_name
  }
}