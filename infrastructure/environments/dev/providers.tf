terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "viet-lab-test"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    encrypt = true //TODO: Implement S3 bucket encryption
  }
}

provider "aws" {
  region = var.region
}

# Data source to get a list of Availability Zones in the current region
data "aws_availability_zones" "available" {
  state = "available"
}