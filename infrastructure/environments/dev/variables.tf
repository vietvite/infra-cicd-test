variable "region" {
  description = "The AWS region to deploy the infrastructure in."
  type        = string
}

variable "project_name" {
  description = "A name for the project to prefix resources."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "eks_admin_whitelisted" {
  description = "A list of allowed IP addresses/CIDRs to access the EKS public API endpoint."
  type        = list(string)
}

variable "node_group_config" {
  description = "Configuration for the EKS node group"
  type = object({
    capacity_type  = string
    instance_types = list(string)
    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })
  })
  default = {
    capacity_type  = "SPOT"
    instance_types = ["t3.small"]
    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 2
    }
  }
}