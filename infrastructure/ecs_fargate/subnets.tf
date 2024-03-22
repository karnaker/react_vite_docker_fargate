# Public Subnets for ALB
resource "aws_subnet" "vite_subnet_public" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.vite_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vite_vpc.cidr_block, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}_${var.environment}_subnet_public_${count.index}"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Private Subnets for ECS Tasks
resource "aws_subnet" "vite_subnet_private" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.vite_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.vite_vpc.cidr_block, 8, count.index + length(var.availability_zones))
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name        = "${var.project_name}_${var.environment}_subnet_private_${count.index}"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
