variable "name" {
  type        = string
  description = "Name prefix for resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to use"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets (one per AZ)"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets (one per AZ)"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC"
  default     = true
}

variable "map_public_ip_on_launch" {
  type        = bool
  description = "Auto-assign public IPs in public subnets"
  default     = true
}

variable "internet_cidr" {
  type        = string
  description = "CIDR for internet routes (IPv4)"
  default     = "0.0.0.0/0"
}
