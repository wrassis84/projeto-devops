provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "k8s-key" {
  key_name   = "k8s-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "k8s-sg" {

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

}

resource "aws_instance" "kubernetes-worker" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.k8s-key.key_name
  count         = 2
  tags = {
    Name = "aws-k8s-node"
    Type = "worker"
  }
  security_groups = ["${aws_security_group.k8s-sg.name}"]
}

resource "aws_instance" "kubernetes-master" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.medium"
  key_name      = aws_key_pair.k8s-key.key_name
  count         = 1
  tags = {
    Name = "aws-k8s-node"
    Type = "master"
  }
  security_groups = ["${aws_security_group.k8s-sg.name}"]
}