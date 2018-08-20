variable "alerts_email" {
  description = "Email address to use when alerting."
}

variable "domain_name" {
  description = "Readthedocs service domain name."
}

variable "environment" {
  description = "Environment type, such as production or test."
}

variable "hosting_zone" {
  description = "Hosting zone name, such as 'com.mydomain.' for example."
}

variable "pg_dbname" {
  description = "Database name."
  default     = "readthedocs"
}

variable "pg_instance_type" {
  description = "Cluster RDS instance type."
  default     = "db.m4.large"
}

variable "pg_password" {
  description = "Database user password."
}

variable "pg_storage_size_gb" {
  description = "Database allocated storage in gigabytes."
  default     = 25
}

variable "pg_username" {
  description = "Database user name."
}

variable "pg_version" {
  description = "Version of database engine to use."
  default     = "10"
}

variable "region" {
  description = "Cluster region."
  default     = "us-west-2"
}

variable "ssh_key" {
  description = "Cluster EC2 instance SSH key name."
}

variable "ssl_policy" {
  description = "The SSL policy to use."
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "subnet" {
  description = "Cluster subnet."
}

variable "tags" {
  description = "Resource tags."
  type        = "map"
}

variable "vpc" {
  description = "Cluster VPC id."
}

variable "web_instance_ami" {
  description = "Cluster EC2 instance AMI id."
  default     = "ami-0574f98a32ba41dd7"  // see https://wiki.debian.org/Cloud/AmazonEC2Image/Stretch for details
}

variable "web_instance_type" {
  description = "Cluster EC2 instance type."
  default     = "m5.large"
}

variable "web_volume_size_gb" {
  description = "Data volume size in gigabytes."
  default     = 25
}
