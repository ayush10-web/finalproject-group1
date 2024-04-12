terraform {
  backend "s3" {
    bucket = "finalprojectacs"
    key    = "prod/network/terraform.tfstate"
    region = "us-east-1"
  }
}