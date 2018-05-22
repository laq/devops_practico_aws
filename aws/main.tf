provider "aws" {
  profile = "s4n"
  region = "us-west-2"
  version = "~> 1.17"
}

module "vpc" {
  source            = "vpc"
  vpc_cidr          = "${var.vpc_cidr}"
  subnet_pub_cidr   = "${var.subnet_pub_cidr}"
  subnet_prv_a_cidr = "${var.subnet_prv_a_cidr}"
  subnet_prv_b_cidr = "${var.subnet_prv_b_cidr}"
}

module "ec2" {
  source            = "ec2"
  vpc_id = "${module.vpc.vpc_id}"
  priv_subnet_ids=["${module.vpc.subnet_prv_a_id}","${module.vpc.subnet_prv_b_id}"]
  pub_subnet_id= "${module.vpc.subnet_pub_id}"
}