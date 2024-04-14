variable "env" {
  default     = "dev"
  type        = string
  description = "Deployment Environment"
}

variable "default_tags" {
  default = {}
  type        = map(any)
  description = "Default tags to be appliad to all AWS resources"
}

variable "prefix" {
  default     = "Group1"
  type        = string
  description = "Group Name"
}

variable "instance_types" {
  default = {
    dev     = "t3.micro"
    prod    = "t3.medium"
    staging = "t3.small"
  }
  type        = map(string)
  description = "Instance types for different environments"
}