variable "name" {
  type        = string
  description = "Name prefix"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ECS tasks (private)"
}

variable "security_group_id" {
  type        = string
  description = "Security group for ECS tasks"
}

variable "execution_role_arn" {
  type        = string
  description = "ECS execution role ARN"
}

variable "task_role_arn" {
  type        = string
  description = "ECS task role ARN"
}

variable "ecr_image" {
  type        = string
  description = "Full image URI (including tag) in ECR"
}

variable "container_port" {
  type        = number
  description = "Container port"
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name"
}

variable "target_group_arn" {
  type        = string
  description = "ALB target group ARN"
}

variable "desired_count" {
  type        = number
  default     = 1
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "environment" {
  type        = map(string)
  description = "Environment variables for the container"
  default     = {}
}
