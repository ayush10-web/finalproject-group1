variable "vpc_cidr_block" {
  default     = "10.1.0.0/16"
  type        = string
  description = "Nonprod cidr block"
}

variable "public_sn" {
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
  type        = list(string)
  description = "Public subnet cidr block"
}

variable "availability_zone" {
  default     = ["us-east-1b", "us-east-1c"]
  type        = list(string)
  description = "Availability zone"
}

variable "private_sn" {
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
  type        = list(string)
  description = "Private subnet cidr block"
}

variable "prod_vpc_cidr" {
  default     = "10.100.0.0/16"
  type        = string
  description = "Prod cidr block"
}

variable "prod_private_sn" {
  default     = ["10.100.3.0/24", "10.100.4.0/24"]
  type        = list(string)
  description = "Public subnet cidr block"
}

