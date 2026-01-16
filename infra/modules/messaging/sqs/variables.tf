variable "name" {
  type        = string
  description = "Name prefix"
}

variable "visibility_timeout_seconds" {
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  type        = number
  default     = 86400
}
