variable "public_sn" {
  default     = ["10.250.0.0/24", "10.250.1.0/24", "10.250.2.0/24"]
  type        = list(string)
  description = "Public subnet cidr block"
}

variable "private_sn" {
  default     = ["10.250.3.0/24", "10.250.4.0/24", "10.250.5.0/24"]
  type        = list(string)
  description = "Private subnet cidr block"
}

variable "prefix" {
  default     = "staging"
  type        = string
  description = "Deployment Environment"
}