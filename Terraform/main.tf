provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.region}"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_vpc" "vpc01" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "vpc01"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc01.id}"
}

resource "aws_subnet" "public-a" {
  vpc_id            = "${aws_vpc.vpc01.id}"
  cidr_block        = "10.1.1.0/24"
  availability_zone = "ap-northeast-1a"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc01.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "rtb"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id      = "${aws_subnet.public-a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# セキュリティグループの書き方は2通り？
# 1. aws_security_groupの中に直接記述
# 2. aws_security_group_rule を作成して、その中でSGを指定 (推奨)
resource "aws_security_group" "web" {
  name        = "common"
  description = "common security group"
  vpc_id      = "${aws_vpc.vpc01.id}"

  tags = {
    Name = "common"
  }
}

resource "aws_security_group_rule" "i_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_public_ip}"]
  security_group_id = "${aws_security_group.web.id}"
}

resource "aws_security_group_rule" "i_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["${var.my_public_ip}"]
  security_group_id = "${aws_security_group.web.id}"
}

resource "aws_security_group_rule" "e_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web.id}"
}

resource "aws_instance" "web01" {
  ami                         = "${lookup(var.amis_centos7, var.region)}"
  instance_type               = "t2.micro"
  key_name                    = "${aws_key_pair.auth.id}"
  subnet_id                   = "${aws_subnet.public-a.id}"
  associate_public_ip_address = true

  vpc_security_group_ids = ["${aws_security_group.web.id}"]

  tags {
    Name = "web01"
    owner = "${var.owner}"
  }
}

resource "aws_eip" "web01" {
  instance = "${aws_instance.web01.id}"
  vpc      = true
}
