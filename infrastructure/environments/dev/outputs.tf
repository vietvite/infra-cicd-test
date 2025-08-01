output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint for your EKS cluster."
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "A command to configure kubectl to connect to the new EKS cluster."
  value       = "aws eks --region ${var.region} update-kubeconfig --name ${module.eks.cluster_name}"
}