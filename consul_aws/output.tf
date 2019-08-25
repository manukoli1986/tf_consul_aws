output "ips1" {
  value = ["${join(",", aws_instance.consul_server_1.*.public_ip)}"]
}

output "ips2" {
  value = ["${join(",", aws_instance.consul_server_2.*.public_ip)}"]
}

output "ips3" {
  value = ["${join(",", aws_instance.consul_server_3.*.public_ip)}"]
}

output "frontend_address -> use 8500 port to access cluster" {
  value = "${aws_elb.consulelb.dns_name}"
}

