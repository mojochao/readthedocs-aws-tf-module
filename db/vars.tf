variable "alerts_sns_topic_arn" {
  description = "The alerts SNS topic ARN."
}

variable "cluster_name" {
  description = "The cluster name."
}

variable "pg_dbname" {
  description = "Database name."
}

variable "pg_password" {
  description = "Database user password."
}

variable "pg_size_gb" {
  description = "The allocated storage in GBs."
}

variable "pg_username" {
  description = "Database user name."
}

variable "pg_version" {
  description = "Version of database engine to use."
  default     = "10"
}

variable "instance_type" {
  description = "The type of DB EC2 Instances to run database service on."
}

variable "region" {
  description = "Environment region."
}

variable "tags" {
  description = "The tags to apply to AWS resources."
  type        = "map"
}

variable "web_security_group_id" {
  description = "Security group id of web tier database clients."
}
