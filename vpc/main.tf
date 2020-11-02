#########
### VPC
#########
data "aws_availability_zones" "az" {}

#Create VPC
resource "aws_vpc" "user_vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "${var.name}-${var.environment}"
  }
}

# Create var.az_count private subnets in different availability zone
resource "aws_subnet" "private_subnet" {
  count             =  var.az_count
  cidr_block        = cidrsubnet(aws_vpc.user_vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.az.names[count.index]
  vpc_id            = aws_vpc.user_vpc.id
  tags = {
    Name = "${var.name}-${var.environment}"
  }
}

# Create var.az_count public subnets in different availability zone
resource "aws_subnet" "public_subnet" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.user_vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  vpc_id                  = aws_vpc.user_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-${var.environment}"
  }
}

# Internate Gateway for the public subnet
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.user_vpc.id
  tags = {
    Name = "${var.name}-${var.environment}"
  }
}


# Route the public subnet traffic through the internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.user_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}


# NAT Gateway with Elastic IP for the private subnet
resource "aws_nat_gateway" "nat_gw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
  depends_on    = [aws_internet_gateway.gw]

  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

# Create a NAT gateway with an EIP for each private subnet to get internet connectivity
resource "aws_eip" "eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

# Route table for the private subnets
resource "aws_route_table" "private_rt" {
  count  = var.az_count
  vpc_id = aws_vpc.user_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gw.*.id, count.index)
  }
  tags = {
    Name        = "${var.name}-${var.environment}"
  }
}

# Explicitely associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private_rt_asso" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_rt.*.id, count.index)
}


#VPC module output
output "vpc_id" {
  value = aws_vpc.user_vpc.id
}

output "private_subnet_id"{
  value = aws_subnet.private_subnet.*.id
}

output "public_subnet_id"{
  value = aws_subnet.public_subnet.*.id
}