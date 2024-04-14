terraform {
  backend "s3" {
    bucket = "finalprojectacs"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-1"
  }
}