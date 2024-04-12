variable "vpc_cidr_block" {
  default     = "10.2.0.0/16"
  type        = string
  description = "Nonprod cidr block"
}

variable "public_sn" {
  default     = "10.2.100.0/24"
  type        = string
  description = "Public subnet cidr block"
}

variable "availability_zone" {
  default     = "us-east-1a"
  type        = string
  description = "Availability zone"
}

variable "private_sn" {
  default     = "10.2.200.0/24"
  type        = string
  description = "Private subnet cidr block"
}

variable "prefix" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}