variable "alerts_sns_topic_arn" {
  description = "The alerts SNS topic ARN."
}

variable "cluster_name" {
  description = "Readthedocs service cluster name."
}

variable "domain_name" {
  description = "Reacthedocs service domain name."
}

variable "environment" {
  description = "Environment type."
}

variable "gunicorn_num_workers" {
  description = "Number of gunicorn workers to use."
}

variable "hosting_zone" {
  description = "Hosting zone name, such as 'com.mydomain.' for example."
}

variable "instance_ami" {
  description = "Cluster EC2 instance AMI id."
}

variable "instance_ssh_key" {
  description = "Cluster EC2 instance SSH key name."
}

variable "instance_type" {
  description = "Cluster EC2 instance type."
}

variable "pg_hostname" {
  description = "Database host address."
}

variable "pg_dbname" {
  description = "Database name."
}

variable "pg_password" {
  description = "Database user password."
}

variable "pg_username" {
  description = "Database user name."
}

variable "region" {
  description = "Cluster region."
}

variable "subnet" {
  description = "Cluster subnet."
}

variable "tags" {
  description = "Resource tags."
  type        = "map"
}

variable "vpc" {
  description = "Cluster vpc."
}

variable "volume_size_gb" {
  description = "Data volume size in gigzbytes."
}
