module "vpc-prod" {
  source     = "../../../Module/aws_network"
  public_sn  = var.public_sn
  private_sn = var.private_sn
  prefix     = var.prefix
}

