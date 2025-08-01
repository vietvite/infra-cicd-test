locals {
  num_subnets_per_type = length(var.azs)
  total_subnets        = local.num_subnets_per_type * 2

  # --- AUTOMATIC CIDR CALCULATION LOGIC ---
  # To divide the VPC CIDR into N subnets, we need to add 'newbits' to the prefix.
  # The number of subnets we can create is 2^newbits.
  # We need to find the smallest 'newbits' such that 2^newbits >= total_subnets.
  # This is equivalent to newbits >= log2(total_subnets).
  # We use ceil() to get the next whole number, ensuring we have enough subnets.
  # Example: 6 total subnets. log2(6) = 2.58. ceil(2.58) = 3. So we need 3 newbits.
  # This divides the VPC into 2^3 = 8 chunks, and we use the first 6.
  subnet_newbits = ceil(log(local.total_subnets, 2))

  # Generate the list of public CIDR blocks automatically
  public_subnet_cidrs = [
    for i in range(local.num_subnets_per_type) : cidrsubnet(var.vpc_cidr, local.subnet_newbits, i)
  ]

  # Generate the list of private CIDR blocks automatically, offsetting the index to avoid overlap
  private_subnet_cidrs = [
    for i in range(local.num_subnets_per_type) : cidrsubnet(var.vpc_cidr, local.subnet_newbits, i + local.num_subnets_per_type)
  ]
  # --- END OF CALCULATION LOGIC ---

  public_subnets = {
    for i, cidr in local.public_subnet_cidrs : "public-${i}" => {
      az              = var.azs[i]
      cidr_block      = cidr
      name            = "${var.project_name}-public-subnet-${var.azs[i]}"
      map_public_ip   = true
      kubernetes_role = "elb"
    }
  }

  private_subnets = {
    for i, cidr in local.private_subnet_cidrs : "private-${i}" => {
      az              = var.azs[i]
      cidr_block      = cidr
      name            = "${var.project_name}-private-subnet-${var.azs[i]}"
      map_public_ip   = false
      kubernetes_role = "internal-elb"
    }
  }

  all_subnets = merge(local.public_subnets, local.private_subnets)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  for_each                = local.all_subnets
  vpc_id                  = aws_vpc.main.id
  availability_zone       = each.value.az
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip

  tags = {
    Name                               = each.value.name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each       = { for k, v in aws_subnet.main : k => v if v.map_public_ip_on_launch }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = { Name = "${var.project_name}-nat-eip" }
}

output "public_subnets" {
  value = local.public_subnets
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.main["public-0"].id # Place NAT in the first public subnet
  depends_on = [aws_internet_gateway.main]
  tags = { Name = "${var.project_name}-nat-gw" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "${var.project_name}-private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each       = { for k, v in aws_subnet.main : k => v if !v.map_public_ip_on_launch }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}