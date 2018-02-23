provider "aws" {
  region     = "us-east-1"
}

module "create_vpc" {
    source = "../../../modules/create_vpc"
    cidr_block = "10.0.0.0/16"
    vpc_name = "test_vpc"
    enable_dns_hostnames = true

    # Create public subnets
    public_subnets = ["10.0.1.0/24"]
    public_subnet_names = ["public_subnet"]

    # Create private subnets
    private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
    private_subnet_names = ["private_subnet1", "private_subnet2"]

    # Create internet Gateway (Only if at least one public subnet is created)
    internet_gateway_name = "default_VPC_gateway"
}