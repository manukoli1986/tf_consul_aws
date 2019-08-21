# Create a new instance of the ami-1234 on an m1.small node
provider "aws" {
    region = "us-east-1"
}


resource "aws_key_pair" "mayank-user" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

