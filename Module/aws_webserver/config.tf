terraform {
  backend "s3" {
    bucket = "finalprojectacs"
    key    = "dev/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}