# VPC
resource "aws_default_vpc" "jenkins-vpc" {
  tags = {
    Name = "Jenkins VPC"
  }
}

# Declare availability zones
data "aws_availability_zones" "available" {}

# subnet
resource "aws_default_subnet" "jenkins-az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Jenkins subnet for ${data.aws_availability_zones.available.names[0]}"
  }
}

# Define the security group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-server-security-group"
  description = "Security group for jenkins-server"

  # Allow HTTP & SSH access from my IP
  dynamic "ingress" {
    for_each = [22, 8080]
    iterator = port
    content {
      description = "SSH & Jenkins Port from My IP"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["90.219.196.189/32"]
    }
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

# Define the SSH key pair
resource "aws_key_pair" "jenkins-key" {
  key_name   = "jenkins-key"
  public_key = file("~/.ssh/jenkins-key.pub")
}

# Define the EC2 instance with Jenkins
resource "aws_instance" "jenkins-server" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.small"
  key_name               = aws_key_pair.jenkins-key.key_name
  subnet_id              = aws_default_subnet.jenkins-az1.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  tags = {
    Name = "jenkins-server"
  }
}

resource "null_resource" "install-jenkins" {

  # ssh into instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/jenkins-key")
    host        = aws_instance.jenkins-server.public_ip
  }

  # copy install_jenkins.sh from local to jenkins-server

  provisioner "file" {
    source      = "./install_jenkins.sh"
    destination = "/tmp/install_jenkins.sh"
  }

  # set permission on install_jenkins.sh to execute
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_jenkins.sh",
      "sh /tmp/install_jenkins.sh"
    ]
  }
  depends_on = [aws_instance.jenkins-server]
}