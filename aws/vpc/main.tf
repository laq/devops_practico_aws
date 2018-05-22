resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags {
    Name = "my_private_cloud"
  }
}

### Subredes
resource "aws_subnet" "subnet_pub" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet_pub_cidr}"
  availability_zone = "us-west-2a"

  tags {
    Name = "snet_pub"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet_prv_a_cidr}"
  availability_zone = "us-west-2a"

  tags {
    Name = "snet_az1"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "${var.subnet_prv_b_cidr}"
  availability_zone = "us-west-2b"

  tags {
    Name = "snet_az2"
  }
}


### Elastic ip for nat gateway
resource "aws_eip" "eip_ngw" {
  vpc      = true
  tags {
    Name = "eip_ngw"
  }
}

### Gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "igw"
  }
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.eip_ngw.id}"
  subnet_id     = "${aws_subnet.subnet_pub.id}"
  tags {
    Name = "ngw"
  }
}

### Routing Tables
resource "aws_route_table" "routing_table_pub" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "rt_pub"
  }
}

resource "aws_route_table" "routing_table_prv" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags {
    Name = "rt_prv"
  }
}

resource "aws_route_table_association" "route_table_association_pub" {
  subnet_id      = "${aws_subnet.subnet_pub.id}"
  route_table_id = "${aws_route_table.routing_table_pub.id}"
}

resource "aws_route_table_association" "route_table_association_prv_a" {
  subnet_id      = "${aws_subnet.subnet_a.id}"
  route_table_id = "${aws_route_table.routing_table_prv.id}"
}

resource "aws_route_table_association" "route_table_association_prv_b" {
  subnet_id      = "${aws_subnet.subnet_b.id}"
  route_table_id = "${aws_route_table.routing_table_prv.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "subnet_pub_id" {
  value = "${aws_subnet.subnet_pub.id}"
}

output "subnet_prv_a_id" {
  value = "${aws_subnet.subnet_a.id}"
}

output "subnet_prv_b_id" {
  value = "${aws_subnet.subnet_b.id}"
}

