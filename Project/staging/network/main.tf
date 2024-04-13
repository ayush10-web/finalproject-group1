module "vpc-dev" {
  source            = "../../../Module"
  public_sn         = var.public_sn
  private_sn        = var.private_sn
  prefix            = var.prefix
}

