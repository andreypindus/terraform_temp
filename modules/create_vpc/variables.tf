variable "cidr_block" {
    description = "Default VPC CIDR block"
}

variable "enable_dns_hostnames" {
    description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
}

variable "vpc_name" {
    description = "A name of the VPC"
}

variable "cidr_block_subnet" {
    description = "Cidr block of the subnet"
}

variable "map_public_ip_on_launch" {
    description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false."
    default = true
}

variable "subnet_name" {
    description = "Name of the subnet"
}