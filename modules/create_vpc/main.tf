# Define locals for use in current module
locals {
  max_subnet_length = "${max(length(var.private_subnets), length(var.public_subnets))}"
}

# Create new VPC
resource "aws_vpc" "new_vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name = "${var.vpc_name}"
  }
}

# Create public subnet
resource "aws_subnet" "new_public_subnet" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  cidr_block = "${var.public_subnets[count.index]}"
  vpc_id = "${aws_vpc.new_vpc.id}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name = "${var.public_subnet_names[count.index]}"
  }
}

# Create private subnet
resource "aws_subnet" "new_private_subnet" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  cidr_block = "${var.private_subnets[count.index]}"
  vpc_id = "${aws_vpc.new_vpc.id}"
  
  tags {
    Name = "${var.private_subnet_names[count.index]}"
  }
}

# Create internet gateway for the VPC
resource "aws_internet_gateway" "vpc_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.new_vpc.id}"

  tags {
    Name = "${var.internet_gateway_name}"
  }
}

# Public routes
resource "aws_route_table" "public" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.new_vpc.id}"
  
  tags {
    Name = "Public route table"
  }
}

resource "aws_route" "public_internet_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.vpc_internet_gateway.id}"
}

# Private routes
  resource "aws_route_table" "private" {
  count = "${local.max_subnet_length > 0 ? local.max_subnet_length : 0}"

  vpc_id = "${aws_vpc.new_vpc.id}"
  
  tags {
    Name = "Private route table"
  }
}

# Create elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  vpc = true
  
  tags {
    Name = "NAT_IP"
  }
}

# Create a NAT Gateway
resource "aws_nat_gateway" "new_nat_gateway" {
  count = "${length(var.public_subnets) > 0 ? 1 : 0}"

  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.new_public_subnet.id}"

  tags {
    Name = "NAT Gateway"
  }

  depends_on = ["aws_internet_gateway.vpc_internet_gateway"]
}

resource "aws_route" "private_nat_gateway" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.new_nat_gateway.id}"
}

# Create S3 endpoint
data "aws_vpc_endpoint_service" "s3" {
  count = "${var.enable_s3_endpoint ? var.enable_s3_endpoint : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.enable_s3_endpoint ? var.enable_s3_endpoint : 0}"

  vpc_id = "${aws_vpc.new_vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${var.enable_s3_endpoint ? length(var.private_subnets) : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${var.enable_s3_endpoint ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

# Create DynamoDB endpoint
data "aws_vpc_endpoint_service" "dynamodb" {
  count   = "${var.enable_dynamodb_endpoint ? 1 : 0}"

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count        = "${var.enable_dynamodb_endpoint ? 1 : 0}"

  vpc_id       = "${aws_vpc.new_vpc.id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${var.enable_dynamodb_endpoint ? length(var.private_subnets) : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = "${var.enable_dynamodb_endpoint ? length(var.public_subnets) : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${aws_route_table.public.id}"
}