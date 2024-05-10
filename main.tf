provider "aws" {
  region     = "us-east-2"
  access_key = "accessKey"
  secret_key = "secretkey"
}


# Create a VPC
resource "aws_vpc" "prodvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Production_vpc"
  }
}

# Create a Subnet

resource "aws_subnet" "prodsubnet1" {
  vpc_id     = aws_vpc.prodvpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-prod"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "gw" {
  vpc_id     = aws_vpc.prodvpc.id

  tags = {
    Name = "IGW"
  }
}

# Create a Route Table

resource "aws_route_table" "prodroute" {
  vpc_id     = aws_vpc.prodvpc.id

  route {
    cidr_block           = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "RT"
  }
}

# Associate the subnet with Route Table

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.prodsubnet1.id
  route_table_id = aws_route_table.prodroute.id
}

# Create a security Group

resource "aws_security_group" "allow_tls" {
  name        = "securityGroup"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id     = aws_vpc.prodvpc.id


ingress {
    description     = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

ingress {
    description     = "HTTPS web traffice from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description     = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }


egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # any ip address / any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "SG_allow_tls"
  }
}
# Create an Instance attach the security group to the instance

resource "aws_instance" "server" {
  ami           = "ami-0ddda618e961f2270"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = aws_subnet.prodsubnet1.id
  key_name   = "ohio_new_kp"


  tags = {
    Name = "Web-Server1"
  }
}

resource "aws_instance" "server1" {
  ami           = "ami-0ddda618e961f2270"
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = aws_subnet.prodsubnet1.id
  key_name   = "ohio_new_kp"


  tags = {
    Name = "Jenkins_Server"
  }
}


