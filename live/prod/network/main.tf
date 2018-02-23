provider "aws" {
  region     = "us-east-1"
}

module "create_vpc" {
    source = "../../../modules/create_vpc"
    cidr_block = "172.16.0.0/16"
    vpc_name = "test_vpc"
    enable_dns_hostnames = true

    public_subnets = []
    public_subnet_names = []

    private_subnets = ["172.16.3.0/20", "172.16.5.0/20"]
    private_subnet_names = ["private1", "private2"]
}