region                = "us-east-1"
project_name          = "labtest"
vpc_cidr              = "10.0.0.0/16"
eks_admin_whitelisted = ["0.0.0.0/0"]
node_group_config = {
  capacity_type  = "SPOT"
  instance_types = ["t3.medium"]
  scaling_config = {
    desired_size = 1
    min_size     = 1
    max_size     = 3
  }
}