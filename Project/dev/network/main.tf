module "vpc-dev" {
  source            = "../../../Module"
  vpc_cidr_block    = var.vpc_cidr_block
  public_sn         = var.public_sn
  private_sn        = var.private_sn
  availability_zone = var.availability_zone
  prefix            = var.prefix
}

