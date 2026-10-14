variable "aws_region" {
  default = "ap-south-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "instance_type" {
  default = "t3.micro"
}

# Ubuntu 22.04 LTS AMI (ap-south-2)
variable "ami_id" {
  default = "ami-0199ac7c9fbf9ed83" 
}