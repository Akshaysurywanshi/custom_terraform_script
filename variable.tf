                                      VARIABLES

 
variable "access_key" { 
 default = "ACCESS_KEY_HERE" 
} 
variable "secret_key" { 
 default = "SECRET_KEY_HERE" 
} 
variable "cidr_vpc" { 
 description = "CIDR block for the VPC" 
 default = "10.1.0.0/16" 
} 
variable "cidr_subnet" { 
 description = "CIDR block for the subnet" 
 default = "10.1.0.0/24" 
} 
variable "availability_zone" { 
 description = "availability zone to create subnet" 
 default = "us-east-1a" 
} 
variable "ec2_key_name" { 
 description = "keypair name for infrastructure" 
 type = string 
 default = "KEY_NAME_HERE" 
} 
variable "instance_ami" { 
 description = "AMI for aws EC2 instance" 
 default = "AMI_ID_HERE" 
} 
variable "instance_type" { 
 description = "type for aws EC2 instance" 
 default = "t5.large" 
} 
variable "environment_tag" { 
 description = "Environment tag" 
 default = "ENVIRONMENT_NAME_HERE" 
} 
variable "name" { 
 description = "Name of service" 
 default = "aaic" 
} 
variable "region" { 
 default = "us-east-1" 
 description = "AWS Region" 
} 
variable "aws_security_group_rules" { 
 description = "security group rules" 
 default = ["SECURITY_RULES_HERE"] 
}
