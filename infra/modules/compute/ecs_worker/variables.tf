variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "cluster_id" {
  type        = string
  description = "Existing ECS cluster id"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "ecr_image" {
  type = string
}

variable "log_group_name" {
  type = string
}

variable "desired_count" {
  type    = number
  default = 0
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
