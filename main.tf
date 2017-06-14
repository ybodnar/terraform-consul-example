provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-east-1"
}

variable "ami" {
  # default = "ami-a591b6b3"
}
variable "instance_type" {
  # default = "m3.medium"
  default = "t2.micro"
}

variable "pk" {
}

resource "aws_key_pair" "hashi_key" {
  key_name   = "hashi-key"
  public_key = "${var.pk}"
}


resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.default.id}"
}

resource "aws_subnet" "default" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "default" {
  name        = "terraform_example"
  description = "Used in the terraform"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "consul" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${aws_key_pair.hashi_key.id}"
  vpc_security_group_ids = ["${aws_security_group.default.id}"]
  subnet_id = "${aws_subnet.default.id}"
  count = 2
  tags = {
    ybhashi_cluster= "demo1"
  }

  provisioner "file" {
      source      = "consul/consul.d"
      destination = "/etc"
  }

  provisioner "file" {
      source      = "aws_conf.sh"
      destination = "/home/ubuntu/aws_conf.sh"
  }

  provisioner "local-exec" {
    command = "source aws_conf.sh ; consul agent ${count.index == 0 ? "-server" : ""} -config-dir=/etc/consul.d"
  }
}
