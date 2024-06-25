# VPC
resource "aws_default_vpc" "kops-vpc" {
  tags = {
    Name = "Kops VPC"
  }
}

# Declare availability zones
data "aws_availability_zones" "available" {}

# subnet
resource "aws_default_subnet" "kops-az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Kops subnet for ${data.aws_availability_zones.available.names[0]}"
  }
}

# Define the security group
resource "aws_security_group" "kops_sg" {
  name        = "kops-server-security-group"
  description = "Security group for kops-server"

  # Allow SSH access from my IP
  dynamic "ingress" {
    for_each = [22]
    iterator = port
    content {
      description = "SSH port from my IP"
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
    Name = "kops_sg"
  }
}

# Define the SSH key pair
resource "aws_key_pair" "kops-key" {
  key_name   = "kop-key"
  public_key = file("~/.ssh/kops-key.pub")
}

# Define the EC2 instance with Kops
resource "aws_instance" "kops-server" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.kops-key.key_name
  subnet_id              = aws_default_subnet.kops-az1.id
  vpc_security_group_ids = [aws_security_group.kops_sg.id]

  tags = {
    Name = "kops-server"
  }
}

data "aws_route53_zone" "selected" {
  name         = "toddblakeman.co.uk"
  private_zone = false
}

resource "aws_route53_record" "domain_Name" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "kops"
  type    = "A"
  records = [aws_instance.kops-server.public_ip]
  ttl     = 300
  depends_on = [
    aws_instance.kops-server
  ]
}

resource "null_resource" "install-kops" {

  # ssh into instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/kops-key")
    host        = aws_instance.kops-server.public_ip
  }

  # copy install_kops.sh from local to kops-server

  provisioner "file" {
    source      = "./install_kops.sh"
    destination = "/tmp/install_kops.sh"
  }

  # set permission on install_kops.sh to execute
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_kops.sh",
      "sh /tmp/install_kops.sh"
    ]
  }
  depends_on = [aws_instance.kops-server]
}