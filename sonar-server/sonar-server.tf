# VPC
resource "aws_default_vpc" "sonar-vpc" {
  tags = {
    Name = "Sonar VPC"
  }
}

# Declare availability zones
data "aws_availability_zones" "available" {}

# subnet
resource "aws_default_subnet" "sonar-az1" {
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Sonar subnet for ${data.aws_availability_zones.available.names[0]}"
  }
}

# Define the security group
resource "aws_security_group" "sonar_sg" {
  name        = "sonar-server-security-group"
  description = "Security group for sonar-server"

  # Allow HTTP & SSH access from my IP
  dynamic "ingress" {
    for_each = [22, 80, 9000, 9001]
    iterator = port
    content {
      description = "SSH & SonarQube Ports from My IP"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
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
    Name = "sonar_sg"
  }
}

# Define the SSH key pair
resource "aws_key_pair" "sonar-key" {
  key_name   = "sonar-key"
  public_key = file("~/.ssh/sonar-key.pub")
}

# Define the EC2 instance with SonarQube
resource "aws_instance" "sonar-server" {
  ami                    = "ami-04b70fa74e45c3917"
  instance_type          = "t2.medium"
  user_data              = file("install_sonar.sh")
  key_name               = aws_key_pair.sonar-key.key_name
  subnet_id              = aws_default_subnet.sonar-az1.id
  vpc_security_group_ids = [aws_security_group.sonar_sg.id]

  tags = {
    Name = "sonar-server"
  }
}