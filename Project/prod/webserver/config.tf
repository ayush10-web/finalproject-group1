terraform {
  backend "s3" {
    bucket = "finalprojectacs"
    key    = "prod/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}