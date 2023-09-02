variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "aws_ecr_repositories" {
  type    = map(any)
  default = {}
}

variable "image_tag_mutability" {
  type = string
}

variable "scan_on_push" {
  type = string
}