terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.52.0"
    }
  }
  backend "s3" {
    bucket = "digital-terraform-states"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = var.region
}