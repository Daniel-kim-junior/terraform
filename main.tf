resource "aws_key_pair" "jiokim" {
  key_name = "jiokim"
  public_key = file("~/.ssh/jiokim.pub")
}

# VPC 리소스 생성
resource "aws_vpc" "my_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "myVPC"
  }
}





# Subnet 리소스 생성
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "mySubnet"
  }
}



resource "aws_default_route_table" "route_main" {
  default_route_table_id = "${aws_vpc.my_vpc.default_route_table_id}"

  tags = { Name = "Public Route Table" }
}

resource "aws_internet_gateway" "my_vpc" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  tags = { Name = "Internet Gateway" }
}

resource "aws_route" "public" {
	route_table_id         = "${aws_vpc.my_vpc.default_route_table_id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id             = "${aws_internet_gateway.my_vpc.id}"
}
resource "aws_eip_association" "eip" {
  instance_id   = aws_instance.ubuntu.id
  public_ip = "43.200.195.187"
}


resource "aws_security_group" "ssh" {
  name = "allow_ssh_from_all"
  description ="Allow SSH port"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port =22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}



# Ubuntu Instance 생성
resource "aws_instance" "ubuntu" {
  ami           = "ami-0225bc2990c54ce9a" # ubuntu 20.04 (64bit, x86)
  instance_type = "t3.micro"
  key_name = aws_key_pair.jiokim.key_name
  subnet_id   = aws_subnet.my_subnet.id
  private_ip = "172.16.10.100"
  vpc_security_group_ids = [
    aws_security_group.ssh.id
  ]
  tags = {
    Name = "myUbuntu"
  }
  
}





