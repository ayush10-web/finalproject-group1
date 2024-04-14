variable "public_sn" {
  default     = ["10.200.0.0/24", "10.200.1.0/24", "10.200.2.0/24"]
  type        = list(string)
  description = "Public subnet cidr block"
}

variable "private_sn" {
  default     = ["10.200.3.0/24", "10.200.4.0/24", "10.200.5.0/24"]
  type        = list(string)
  description = "Private subnet cidr block"
}

variable "prefix" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}