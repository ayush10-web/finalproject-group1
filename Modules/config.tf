terraform {
  backend "s3" {
    bucket = "assignment1an"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}