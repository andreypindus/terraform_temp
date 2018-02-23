resource "aws_vpc" "new_vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "new_public_subnet" {
  count = "${length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  cidr_block = "${var.public_subnets[count.index]}"
  vpc_id = "${aws_vpc.new_vpc.id}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name = "${var.public_subnet_names[count.index]}"
  }
}

resource "aws_subnet" "new_private_subnet" {
  count = "${length(var.private_subnets) > 0 ? length(var.private_subnets) : 0}"

  cidr_block = "${var.private_subnets[count.index]}"
  vpc_id = "${aws_vpc.new_vpc.id}"
  tags {
    Name = "${var.private_subnet_names[count.index]}"
  }
}