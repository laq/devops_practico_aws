resource "aws_security_group" "allow_outbound" {
  name        = "allow_all_outbound"
  description = "Allow all outbound"
  vpc_id      = "${var.vpc_id}"
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all_outbound"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_web"
  }
}

resource "aws_security_group" "allow_web8080" {
  name        = "allow_web8080"
  description = "Allow web 8080"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_web8080"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh"
  vpc_id      = "${var.vpc_id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_ssh"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("${path.module}/deployer-key.pub")}"  
}

resource "aws_instance" "bastion" {
  ami                          = "ami-b5ed9ccd"
  subnet_id                    = "${var.pub_subnet_id}"
  instance_type                = "t2.nano"
  key_name                     = "${aws_key_pair.deployer.key_name}"
  associate_public_ip_address  = true
  vpc_security_group_ids       = ["${aws_security_group.allow_ssh.id}","${aws_security_group.allow_web8080.id}","${aws_security_group.allow_outbound.id}"]
  tags {
    Name = "Jenkins"
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/init.tpl")}"
}

resource "aws_instance" "server" {
  ami                    = "ami-b5ed9ccd"
  subnet_id              = "${element(var.priv_subnet_ids,count.index)}"
  instance_type          = "t2.nano"
  key_name               = "${aws_key_pair.deployer.key_name}"
  count                  = 2
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}","${aws_security_group.allow_web.id}","${aws_security_group.allow_outbound.id}"]
  tags {
    Name = "${element(var.env,count.index)}-server"
  }
  user_data = "${data.template_file.init.rendered}"
}


resource "aws_elb" "server_loadbalancer" {
  name               = "server-elb"
  subnets            = ["${var.priv_subnet_ids[1]}","${var.pub_subnet_id}"]
  security_groups    = ["${aws_security_group.allow_web.id}","${aws_security_group.allow_outbound.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }
  instances             = ["${aws_instance.server.*.id}"]
}

