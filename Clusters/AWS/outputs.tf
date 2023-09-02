## https://www.terraform.io/docs/language/values/outputs.html
output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = var.cluster_name
}

output "cluster_region" {
  description = "EKS Cluster Region"
  value       = var.region
}

output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS Cluster ARN"
  value       = module.eks.cluster_arn
}

output "console_url" {
  description = "AWS Console URL"
  value       = "https://${var.region}.console.aws.amazon.com/ecs/home?region=${var.region}#/clusters"
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "worker_security_group_id" {
  value = module.eks.worker_security_group_id
}