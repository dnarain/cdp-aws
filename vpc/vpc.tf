##   Terraform to set up a VPC for CDP w/ CCM (Private IPs) enabled
##   dnarain@cloudera.com

## This TF will create the following artifacts
## 1x VPC (with the CIDR specified in the variable VPC_CIDR)
## 1x Internet Gateway (attached to this VPC)
## 1x Route Table that has a default route to the Internet Gatway
## 3x Public Subnets (Map Public IP on Launch Flag = True, w/ above route table)
## 3x Elastic IPs
## 3x NAT Gateways - one per public subnet
## 3x Route tables that have a default route to the NAT Gateway in a subnet
## 3x Private Subnets (with above route table, Map Public IP on Launch Flag = False)
## NOTE: The VPC doesn't have a default route to the IGW, this is by design

# if you want the generated artifacts to have a prefix to their name, then 
# specify it here or use the -var argument on the command line

## NOTES:
## Most resources will be created in 20 seconds or less per resource, but:
## It takes time to create NAT Gatways - expect this step to take up to 3 mins
## It also takes time to destroy NAT Gatways - expect this step to take 1-2 mins

#### 
#### VARIABLES GO HERE
#### 
variable "PREFIX" {
  description = "Prefix for names of created objects (e.g. CDPPOC_)"
  default = ""
}

# You can change the default VPC CIDR here - its 10.0.0.0/16 by default
# We will be dividing this CIDR into 6 equal size subnets
variable "VPC_CIDR" {
  description = "The CIDR block for the VPC, e.g: 10.0.0.0/16"
  type = string
  default = "10.0.0.0/16"
}

# Subnet CIDR allocation logic is very simplistic - we create 6 subnets,
# all of equal size.  They are created by adding a number of additional 
# bits to the prefix of the VPC CIDR.  
# By default we add 8 bits, so a /16 CIDR for the VPC translates into
# a /24 CIDR for the subnets

variable "SUBNET_CIDR_NEWBITS" {
  description = "In a /16 VPC, 8 will make /24 subnets, 2 will make /18 subnets etc."
  default = 8
}

variable "AZs" {
  type = list
  default = [ "us-east-1a", "us-east-1b", "us-east-1c"]
}

## The VPC has an internet gateway and DNS options enabled 
resource "aws_vpc" "the_vpc" {
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "${var.PREFIX}cdp-vpc"
    }
}

## there seems to be a strange bug in terraform .12
## if I use the {} sytax, then I get an error that I'm using deprecated interpolation syntax
## But, if I don't supply the {} around the vpc reference, then the reference is invalid

resource "aws_internet_gateway" "the_igw" {
    vpc_id=aws_vpc.the_vpc.id
    tags = {
        Name = "${var.PREFIX}cdp-igw"
    }
}


# ## Before you set up the public subnets, set up the routing table they will use
#  resource "aws_route_table" "the_public_route" {
#       vpc_id="${aws_vpc.the_vpc.id}"

#       route {
#           cidr_block = "0.0.0.0/0"
#           gateway_id = "${aws_internet_gateway.the_igw.id}"
#       }

#       tags = {
#           Name = "${var.PREFIX}cdp-publicroute"
#       }
#   }

# ## Create a public subnets and have them route to the IGW. 
# resource "aws_subnet" "public_subnets" {
#   count = 3
#   vpc_id = "${aws_vpc.the_vpc.id}"
#   cidr_block = "${cidrsubnet(aws_vpc.the_vpc.cidr_block, var.SUBNET_CIDR_NEWBITS, count.index)}"
#   availability_zone = "${var.AZs[count.index]}"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "${var.PREFIX}cd-public-subnet-${count.index}"
#   }
# }
  
#  resource "aws_route_table_association" "public_rt_associations" {
#    count = 3
#    subnet_id = "${aws_subnet.public_subnets[count.index].id}"
#    route_table_id = "${aws_route_table.the_public_route.id}"
#  }

# resource "aws_eip" "elastic_ips" {
#   count = 3
#   vpc = true
#   tags = {
#     Name = "${var.PREFIX}cdp-eip-${count.index}"
#   }
# }

# resource "aws_nat_gateway" "nat_gws" {
#   count = 3
#   allocation_id = "${aws_eip.elastic_ips[count.index].id}"
#   subnet_id = "${aws_subnet.public_subnets[count.index].id}"
#    tags = {
#     Name = "${var.PREFIX}cdp-natgw-${count.index}"
#   }
# }


# resource "aws_subnet" "private_subnets" {
#   count = 3
#   vpc_id = "${aws_vpc.the_vpc.id}"
#   cidr_block = "${cidrsubnet(aws_vpc.the_vpc.cidr_block, var.SUBNET_CIDR_NEWBITS, count.index+3)}"
#   availability_zone = "${var.AZs[count.index]}"
#   tags = {
#         Name = "${var.PREFIX}cdp-private-subnet-${count.index}"
#     }
# }

# resource "aws_route_table" "private_routes" {
#     count = 3
#     vpc_id = "${aws_vpc.the_vpc.id}"
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = "${aws_nat_gateway.nat_gws[count.index].id}"
#     }
#     tags = {
#         Name = "${var.PREFIX}cdp-private-route-table-${count.index}"
#     }
# }

# resource "aws_route_table_association" "private_rt_associations" {
#     count = 3
#     subnet_id = "${aws_subnet.private_subnets[count.index].id}"
#     route_table_id = "${aws_route_table.private_routes[count.index].id}"
# }