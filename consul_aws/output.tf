output "ec2_global_ips" {
  value = ["${aws_instance.consul_server_1.*.public_ip}"]
}
