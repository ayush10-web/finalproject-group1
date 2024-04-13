variable "env" {
  default     = "prod"
  type        = string
  description = "Deployment Environment"
}

variable "instance_types" {
  default = {
    dev     = "t3.micro"
    prod    = "t3.micro"
    staging = "t3.small"
  }
  type        = map(string)
  description = "Instance types for different environments"
}