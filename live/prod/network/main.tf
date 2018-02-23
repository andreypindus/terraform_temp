provider "aws" {
  region     = "us-east-1"
}

module "create_vpc" {
    source = "../../../modules/create_vpc"
    cidr_block = "172.16.0.0/16"
    vpc_name = "test_vpc"
    enable_dns_hostnames = true
    
    cidr_block_subnet = "172.16.3.0/20"
    subnet_name = "public_subnet"
}