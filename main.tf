variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}


provider "aws" {
  region     = "us-west-2"
  access_key = "${var.AWS_ACCESS_KEY}"
  secret_key = "${var.AWS_SECRET_KEY}"
}

resource "aws_key_pair" "<your_key_name>" {
  key_name   = "<your_key_name>"
  public_key = "<your_public_key>"}
module "vpc" {
  source             = "github.com/segmentio/stack//vpc"
  name               = "your_vpc"
  environment        = "staging"
  cidr               = "10.30.0.0/16"
  internal_subnets   = ["10.30.0.0/24"]
  external_subnets   = ["10.30.100.0/24"]
  availability_zones = ["us-west-2c"] # take care to match provider and specific availability zone
}
module "bastion" {
  source          = "github.com/segmentio/stack//bastion"
  region          = "us-west-2" # should match the provider
  environment     = "staging"
  key_name        = "<your_key_name>"
  vpc_id          = "${module.vpc.id}"
  subnet_id       = "${module.vpc.external_subnets[0]}"
  security_groups = "${aws_security_group.bastion.id}"
}
resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow SSH traffic to bastion"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "pg" {
  count = "10"
  ami      = "ami-***" #AMI_ID of the packer created image
  key_name = "${aws_key_pair.<your_key_name>.key_name}"
  instance_type = "t2.micro"
  subnet_id                   = "${module.vpc.internal_subnets[0]}"
  vpc_security_group_ids      = ["${aws_security_group.instance.id}"]
  associate_public_ip_address = false
  tags{
     Name = "pg-${count.index}"
  }
}
resource "aws_security_group" "instance" {
  name        = "instance"
  description = "Allow SSH traffic from bastion"
  vpc_id      = "${module.vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion.id}"] # only the bastion SG can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
output "bastion-ip" {
  value = "${module.bastion.external_ip}"
}

output "nat-ips" {
  value = "${module.vpc.internal_nat_ips}"
}
