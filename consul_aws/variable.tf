variable "AWS_ACCESS_KEY_ID" {
  default = "$(aws configure get aws_access_key_id)"
}
variable "AWS_SECRET_ACCESS_KEY" {
  default = "$(aws configure get aws_secret_access_key)"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "region_azs" {
  type = "map"
  default = {
    az1 = "us-east-1a"
    az2 = "us-east-1b"
    az3 = "us-east-1c"
  }
}

variable "key_name" {
  default = "mayank-user"
}
variable "user" {
  default = "ec2-user"
}
variable "public_key_path" {
  default = "/vagrant/mayank-user.pub"
}
variable "priv_key_path" {
  default = "/vagrant/mayank-user"
}
variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}
variable "consul_subnet_cidr1" {
  description = "CIDR for the Consul Subnet 1"
  default     = "10.0.1.0/24"
}
variable "consul_subnet_cidr2" {
  description = "CIDR for the Consul Subnet 2"
  default     = "10.0.2.0/24"
}
variable "consul_subnet_cidr3" {
  description = "CIDR for the Consul Subnet 3"
  default     = "10.0.3.0/24"
}
variable "owner" {
  description = "Infra Owner"
  default     = "Mayank Koli"
}
variable "environment" {
  description = "Infra Env"
  default     = "Consul"
}
variable "connection_timeout" {
  default = "120s"
}

terraform {
  backend "s3" {
    region  = "us-east-1"
    bucket  = "tf-remote-state-test-eu-east-1"
    key     = "terraform.tfstate"
    encrypt = true
  }
}

