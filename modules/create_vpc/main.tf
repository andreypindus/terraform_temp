resource "aws_vpc" "new_vpc" {
  cidr_block = "${var.cidr_block}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"

  tags {
    Name = "${var.vpc_name}"
  }
}

resource "aws_subnet" "new_subnet" {
  cidr_block = "${var.cidr_block_subnet}"
  vpc_id = "${aws_vpc.new_vpc.id}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags {
    Name = "${var.subnet_name}"
  }
}