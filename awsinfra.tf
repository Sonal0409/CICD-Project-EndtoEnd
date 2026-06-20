
provider "aws" {

region = "us-east-2"

}

resource "aws_vpc" "edu-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "edu-vpc"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.edu-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "edu-subnet"
  }
  depends_on = [aws_vpc.edu-vpc]
  map_public_ip_on_launch = true
}

resource "aws_route_table" "edu-route-table" {
  vpc_id = aws_vpc.edu-vpc.id
  tags = {
   Name = "edu-route-table"


 }

}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet-1.id
  route_table_id = aws_route_table.edu-route-table.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.edu-vpc.id

  tags = {
    Name = "edu-ig"
  }
}


resource "aws_route" "edu-route" {
  route_table_id            = aws_route_table.edu-route-table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id

}


resource "aws_security_group" "edu-sg" {
  name        = "web-rules"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.edu-vpc.id

  tags = {
    Name = "edu-rules"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
     }
 ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }
 ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     }

}


resource "aws_instance" "edu-ec2" {
  ami           = "ami-0ea1cddefe0c4aed5"
  instance_type = "t2.medium"
  subnet_id = aws_subnet.subnet-1.id
  security_groups = [aws_security_group.edu-sg.id]
  key_name = "02dec"
  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update
                 sudo apt install openjdk-21-jre-headless -y
                 sudo apt install docker.io -y
                 sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
                 echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
                 sudo apt update
                 sudo apt install jenkins -y
                 EOF

  tags = {
    Name = "CICD-project"
  }
}
