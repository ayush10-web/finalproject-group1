variable "prefix" {
  default     = "dev"
  type        = string
  description = "Environment Type"
}

variable "vpc_cidr_blocks" {
  default = {
    dev     = "10.100.0.0/16"
    prod    = "10.200.0.0/16"
    staging = "10.250.0.0/16"
  }
  type        = map(string)
  description = "Nonprod cidr block"
}

variable "public_sn" {
  default     = ["10.100.1.0/24", "10.100.2.0/24"]
  type        = list(string)
  description = "Public subnet cidr block"
}

variable "availability_zone" {
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type        = list(string)
  description = "Availability zone"
}

variable "private_sn" {
  default     = ["10.100.4.0/24", "10.100.5.0/24"]
  type        = list(string)
  description = "Private subnet cidr block"
}
