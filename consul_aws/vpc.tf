resource "aws_vpc" "consul" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
  }
}
