variable "project_name" {
  description = "Name of the project."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "azs" {
  description = "A list of Availability Zones to create subnets in. One public and one private subnet will be created per AZ."
  type        = list(string)
}