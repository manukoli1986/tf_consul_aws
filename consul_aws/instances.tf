

# server-1
resource "aws_instance" "consul_server_1" {
  ami               = "ami-0b898040803850657"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  count             = "1"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = "${aws_subnet.consul_1.id}"

  provisioner "remote-exec" {
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.priv_key_path)}"
      agent       = "false"
      }

    inline = [
      "sudo amazon-linux-extras install docker -y && sudo systemctl start docker && sudo systemctl enable docker",
      "sudo docker run -d --net host consul agent -node consul-1 -server -ui -client=0.0.0.0 -bootstrap-expect=3 -advertise ${self.private_ip}"
    ]
  }
  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "consul-server-1"
  }
}

# server-2
resource "aws_instance" "consul_server_2" {
  ami               = "ami-0b898040803850657"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1b"
  count             = "1"
  depends_on        = ["aws_instance.consul_server_1"]
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = "${aws_subnet.consul_2.id}"

  provisioner "remote-exec" {
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.priv_key_path)}"
      agent       = "false"
      }

    inline = [
      "sudo amazon-linux-extras install docker -y && sudo systemctl start docker && sudo systemctl enable docker",
      "sudo docker run -d --net host consul agent -node consul-2 -server -ui -client=0.0.0.0 -bootstrap-expect=3 -advertise ${self.private_ip} -join ${aws_instance.consul_server_1[count.index].private_ip}"
    ]
  }
  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "consul-server-2"
  }
}


# server-3
resource "aws_instance" "consul_server_3" {
  ami               = "ami-0b898040803850657"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1c"
  count             = "1"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.consul.id}", "${aws_security_group.consul_internet_access.id}"]
  subnet_id              = "${aws_subnet.consul_3.id}"

  provisioner "remote-exec" {
    connection {
      host        = "${self.public_ip}"
      type        = "ssh"
      user        = "${var.user}"
      private_key = "${file(var.priv_key_path)}"
      agent       = "false"
      }

    inline = [
      "sudo amazon-linux-extras install docker -y && sudo systemctl start docker && sudo systemctl enable docker",
      "sudo docker run --rm  --net host consul agent -node consul-3 -server -ui -client=0.0.0.0 -bootstrap-expect=3 -advertise ${self.private_ip} -join ${aws_instance.consul_server_1[count.index].private_ip}"
    ]
  }
  tags = {
    Owner       = "${var.owner}"
    Terraform   = true
    Environment = "${var.environment}"
    Name        = "consul-server-3"
  }
}
