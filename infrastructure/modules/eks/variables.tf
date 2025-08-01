variable "cluster_name" {
  description = "The name for the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the cluster will be deployed."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for EKS."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes."
  type        = list(string)
}

variable "allowed_admin_ips" {
  description = "List of IPs to allow access to the public API endpoint."
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
    instance_types = ["t3.medium"]
    scaling_config = {
      desired_size = 1
      min_size     = 1
      max_size     = 3
    }
  }
}