terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.28.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.2.3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  default_tags {
    tags = {
      module = var.module
      mail = var.mail
    }
  }
}

resource "aws_instance" "firstVM" {
  count = length(var.hostnames)
#centos  ami = "ami-0b4c74d41ee4bed78" 
  ami= "ami-0a5b5c0ea66ec560d"
  instance_type = "t2.micro"
  subnet_id = "subnet-0ad1301447bbd54f2"
  associate_public_ip_address = true
  key_name = aws_key_pair.test_key.key_name
  tags = {
    Name = "${var.hostnames[count.index]}"
  }
}

resource "aws_key_pair" "test_key" {
  key_name = "test_key22"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDbwWMWegn7bI2gOJS8GUgdpEFeVe8pYBQi+LBlDLMCwWipkzndy4J/nOEAEn1+nnCM6nCTMif9ebIEJfSeKyiPhKJZWBMR6BU0yEb9ecXNiaeEkCuRpfepoIBZGseVFV4NVrNew9k0rJAwvuTfUqHDjFVbG8axDgQ2aQus595YMR0UHSUS2Fj7E9V7Nq0r8HrLmc4vyxtqYjI90WPt9HNG1gex9dZEQKXxjw1HBNs6F6RGL4n3iXvoJ7Lx2df4ZAoIaxrmGCg7IG+JXQ3HskbMVUf7gZn8Nf0kRRk5T7jdNnDTfiZbWj1tYGPZO6OfxOpD3Mt0HtNz/lnsDv2zyICx root@vacent7"
}

resource "local_file" "inv" {
  content = templatefile("templ.tftpl", {lists = {names = aws_instance.firstVM[*].tags.Name, ips = aws_instance.firstVM[*].public_ip}} )
  filename = var.path
}

