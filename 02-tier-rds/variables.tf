variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name in the selected region"
  type        = string
  default     = "Akash_hyd"
}

variable "my_ip_cidr" {
  description = "Your public IPv4 address with /32 for SSH access"
  type        = string
}

variable "db_instance_class" {
  description = "RDS PostgreSQL instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Application database name"
  type        = string
  default     = "flaskdb"
}

variable "db_username" {
  description = "Application database username"
  type        = string
  default     = "flaskuser"
}
