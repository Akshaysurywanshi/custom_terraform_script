                           TERRAFORM SCRIPT

 
terraform { 
 required_providers { 
 aws = { 
 source = "hashicorp/aws" 
 version = "~> 3.27" 
 } 
 } 
 required_version = ">= 0.14.9" 
} 
provider "aws" { 
 access_key = var.access_key 
 secret_key = var.secret_key 
 profile = "default" 
 region = var.region 
} 
# VPC with defined CIDR block, enable DNS support and 
# DNS hostnames so each instance can have a DNS name along with IP address. 
resource "aws_vpc" "vpc" { 
 cidr_block = var.cidr_vpc 
 enable_dns_support = true 
 enable_dns_hostnames = true 
 tags = { 
 "Environment" = "${var.environment_tag}" 
 "Name" = "${var.name}" 
 } 
} 
# The subnet is added inside VPC with its own CIDR block 
# which is a subset of VPC CIDR block inside given availability zone. 
resource "aws_subnet" "subnet_public" { 
 vpc_id = aws_vpc.vpc.id 
 cidr_block = var.cidr_subnet 
 map_public_ip_on_launch = "true" 
 availability_zone = var.availability_zone 
 tags = { 
 "Environment" = "${var.environment_tag}" 
 "Name" = "${var.name}" 
 } 
} 
# Internet gateway needs to be added inside VPC 
# which can be used by subnet to access the internet from inside. 
resource "aws_internet_gateway" "igw" { 
 vpc_id = aws_vpc.vpc.id 
 tags = { 
 "Environment" = "${var.environment_tag}" 
 "Name" = "${var.name}" 
 } 
} 
# Route table, which uses internet gateway to access the internet. 
resource "aws_route_table" "rtb_public" { 
 vpc_id = aws_vpc.vpc.id 
 route { 
 cidr_block = "0.0.0.0/0" 
 gateway_id = aws_internet_gateway.igw.id 
 } 
 tags = { 
 "Environment" = "${var.environment_tag}" 
 "Name" = "${var.name}" 
 } 
} 
# Route table, associate it with the subnet to make our subnet public. 
resource "aws_route_table_association" "rta_subnet_public" { 
 subnet_id = aws_subnet.subnet_public.id 
 route_table_id = aws_route_table.rtb_public.id 
} 
# security group which can be attached to our EC2 instance while creation. 
resource "aws_security_group" "sg_aaic" { 
 name = "sg_aaic" 
 vpc_id = aws_vpc.vpc.id 
 # SSH access from the VPC 
 ingress { 
 from_port = 22 
 to_port = 22 
 protocol = "tcp" 
 cidr_blocks = "${var.aws_security_group_rules}" 
 } 
 egress { 
 from_port = 0 
 to_port = 0 
 protocol = "-1" 
 cidr_blocks = "${var.aws_security_group_rules}" 
 } 
 tags = { 
 "Environment" = var.environment_tag 
 "Name" = "${var.name}" 
 } 
} 
# EC2 instances within our public subnet with created key pair and security group. 
resource "aws_instance" "FrontWebServer" { 
 ami = var.instance_ami 
 instance_type = var.instance_type 
 subnet_id = aws_subnet.subnet_public.id 
 vpc_security_group_ids = ["${aws_security_group.sg_aaic.id}"] 
 key_name = "${var.ec2_key_name}" 
 tags = { 
 "Environment" = "${var.environment_tag}" 
 "Name" = "aaic_FrontWebServe" 
 } 
} 
resource "aws_instance" "BackWebServer" { 
 ami = var.instance_ami 
 instance_type = var.instance_type 
 subnet_id = aws_subnet.subnet_public.id 
 vpc_security_group_ids = ["${aws_security_group.sg_aaic.id}"] 
 key_name = var.ec2_key_name 
 tags = { 
 "Environment" = "${var.environment_tag}" 
 "Name" = "aaic_BackWebServer" 
 } 
} 
# Network LB 
resource "aws_lb" "aaic" { 
 name = "aaic-lb-tf" 
 internal = false 
 load_balancer_type = "network" 
 subnets = [for subnet in aws_subnet.subnet_public: subnet_id] 
 enable_deletion_protection = true 
 tags = { 
 Environment = "${var.environment_tag}" 
 } 
} 
