provider "aws" {
  profile = "s4n"
  region = "us-west-2"
  version = "~> 1.17"
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

resource "aws_security_group" "allow_web8080" {
  name        = "allow_web8080"
  description = "Allow web 8080"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_all"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file("${path.module}/deployer-key.pub")}"  
}

resource "aws_instance" "jenkins" {
  ami           = "ami-6b8cef13"
  instance_type = "t2.nano"
  key_name = "${aws_key_pair.deployer.key_name}"
  security_groups = ["${aws_security_group.allow_ssh.name}","${aws_security_group.allow_web8080.name}"]
}

variable "env" {
  description = "Environments to Initialize"
  type = "list"
  default = ["produccion", "integracion"]
}

resource "aws_instance" "server" {
  ami           = "ami-6b8cef13"
  instance_type = "t2.nano"
  count = 2
  security_groups = ["${aws_security_group.allow_ssh.name}","${aws_security_group.allow_web.name}"]
  tags {
    Name = "${element(var.env,count.index)}-server"
  }
}




