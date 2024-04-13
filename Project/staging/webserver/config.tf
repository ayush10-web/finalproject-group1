terraform {
  backend "s3" {
    bucket = "finalprojectacs"
    key    = "staging/webserver/terraform.tfstate"
    region = "us-east-1"
  }
}