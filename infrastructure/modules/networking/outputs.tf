output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of IDs for the public subnets."
  # Use a 'for' expression to loop through the created subnets and filter for public ones
  value       = [for subnet in aws_subnet.main : subnet.id if subnet.map_public_ip_on_launch]
}

output "private_subnet_ids" {
  description = "A list of IDs for the private subnets."
  # Use a 'for' expression to loop through the created subnets and filter for private ones
  value       = [for subnet in aws_subnet.main : subnet.id if !subnet.map_public_ip_on_launch]
}