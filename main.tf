#set a provider
provider "aws" {
  region = "eu-west-1"
}
# create vpc
resource "aws_vpc" "app_python_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
  Name = var.Name
  }
}
#create a subnet
resource "aws_subnet" "python_subnet" {
  vpc_id = "${aws_vpc.app_python_vpc.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-west-1a"
  tags = {
  Name = var.Name
  }
}
#aws security group creation
resource "aws_security_group" "app_sg_python_app" {
  name = "eng48-rasmus-python-app"
  description = "Allow :80 and :22 inbound traffic"
  vpc_id = "${aws_vpc.app_python_vpc.id}"
  tags = {
  Name = var.Name
  }
  ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}
#Route table
resource "aws_route_table" "app_route" {
vpc_id = aws_vpc.app_python_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_gateway.id
    }
  tags = {
  Name = var.Name
  }
}
# Route table associations
resource "aws_route_table_association" "app_assoc" {
subnet_id = aws_subnet.python_subnet.id
route_table_id = aws_route_table.app_route.id

}
# security
resource "aws_internet_gateway" "app_gateway" {
vpc_id = aws_vpc.app_python_vpc.id
tags = {
Name = var.Name
}
}
#Launch an instance
resource "aws_instance" "app_instance" {
ami          = "ami-067bf2b5ff598f6ba"
subnet_id = "${aws_subnet.python_subnet.id}"
key_name = "rasmus_kilp_eng48_first_key"
vpc_security_group_ids = ["${aws_security_group.app_sg_python_app.id}"]
instance_type = "t2.micro"
associate_public_ip_address = true
user_data = data.template_file.app_init.rendered
tags = {
  Name = var.Name
}
}
# Send bash script - sh file
data "template_file" "app_init" {
  template = "${file("./scripts/init_script.sh.tpl")}"
}
