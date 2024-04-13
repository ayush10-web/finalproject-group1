terraform {
  backend "s3" {
    bucket = "finalprojectacs"
    key    = "staging/network/terraform.tfstate"
    region = "us-east-1"
  }
}