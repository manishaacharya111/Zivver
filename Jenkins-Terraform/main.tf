resource "aws_security_group" "Jenkins-sg" {
  name        = "Jenkins-Security Group"
  description = "Open 22,443,80,8080,9000,9100,9090,3000"

  # Define a single ingress rule to allow traffic on all specified ports
  ingress = [
    for port in [22, 80, 443, 8080,3000] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = var.ami  #change your ami value according to your aws instance
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Jenkins-sg.id]
  user_data              = templatefile("./script/script.sh", {})

  tags = {
    Name = "jenkins"
  }
  root_block_device {
    volume_size = 15
  }
  depends_on = [aws_eip.jenkins_eip]
}

resource "aws_eip" "jenkins_eip" {
  domain = "vpc"

  tags = {
    Name = "jenkins-eip"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins_eip.id
}
