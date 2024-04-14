module "staging-webserver"{
  source     = "../../../Module/aws_webserver"
  env        = var.env
}