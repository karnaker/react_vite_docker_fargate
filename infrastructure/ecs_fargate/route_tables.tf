# Create a route table for public subnets to route traffic to the internet through the Internet Gateway
resource "aws_route_table" "vite_public_rt" {
  vpc_id = aws_vpc.vite_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vite_igw.id
  }

  tags = {
    Name        = "${var.project_name}_${var.environment}_public_rt"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}

# Associate the public route table with the public subnets
resource "aws_route_table_association" "vite_public_rta" {
  count = length(aws_subnet.vite_subnet_public.*.id)

  subnet_id      = aws_subnet.vite_subnet_public[count.index].id
  route_table_id = aws_route_table.vite_public_rt.id
}
