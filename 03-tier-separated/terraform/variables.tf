variable "project_name" {
  description = "Name prefix for resources in the three-tier project"
  type        = string
  default     = "flask-3tier-lab"
}

variable "vpc_cidr" {
  description = "CIDR block for the project VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two Availability Zones for the lab"
  type        = list(string)
  default     = ["ap-south-2a", "ap-south-2b"]
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "flaskdb"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "flaskadmin"
}

variable "db_instance_class" {
  description = "RDS instance class for the learning lab"
  type        = string
  default     = "db.t3.micro"
}

variable "db_password" {
  description = "Temporary lab database password supplied outside version control"
  type        = string
  sensitive   = true
  nullable    = false
}
