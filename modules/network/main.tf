data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Main-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Main-igw"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-2"
  }
}


resource "aws_route_table" "vpc_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "route-ig"
  }
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.vpc_route.id
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.vpc_route.id
}


output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "subnet_id_1" {
  value = aws_subnet.public_subnet_1.id
}

output "subnet_id_2" {
  value = aws_subnet.public_subnet_2.id
}
