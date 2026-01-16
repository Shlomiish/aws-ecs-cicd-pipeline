variable "name" { type = string }

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for client static files"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB DNS name (no http://)"
}

variable "bucket_regional_domain_name" {
  type = string
}

variable "bucket_arn" {
  type = string
}
