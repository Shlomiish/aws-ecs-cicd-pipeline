variable "name" {
  type        = string
  description = "Project name prefix"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention"
}

variable "ecr_repositories" {
  type = list(string)
}

variable "server_port" {
  type        = number
  description = "Server port"
  default     = 3000
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "server_image" {
  type        = string
  description = "ECR image URI with tag for server"
}

variable "server_desired_count" {
  type    = number
  default = 1
}

variable "consumer_image" {
  type        = string
  description = "ECR image URI with tag for consumer"
}

variable "consumer_desired_count" {
  type    = number
  default = 0
}


variable "client_bucket_name" {
  type        = string
  description = "Client static site bucket"
}
