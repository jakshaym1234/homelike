#VPC
resource "aws_vpc" "homelikevpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = merge({ Name = "vpc-homelike" }, var.tags)
}
#Subnets
resource "aws_subnet" "nginx" {
  vpc_id            = aws_vpc.homelikevpc.id
  for_each          = var.subnet_nginx_details
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge({ Name = each.key }, var.tags)
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.homelikevpc.id
  for_each          = var.subnet_app_details
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge({ Name = each.key }, var.tags)
}
resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.homelikevpc.id
  for_each          = var.subnet_db_details
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge({ Name = each.key }, var.tags)
}
resource "aws_subnet" "alb" {
  vpc_id            = aws_vpc.homelikevpc.id
  for_each          = var.subnet_alb_details
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge({ Name = each.key }, var.tags)
}
resource "aws_subnet" "vpn" {
  vpc_id            = aws_vpc.homelikevpc.id
  for_each          = var.subnet_vpn_details
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = merge({ Name = each.key }, var.tags)
}
#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.homelikevpc.id
  tags   = merge({ Name = "igw-homelike" }, var.tags)
}
#NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}
resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.alb["subnet-alb1"].id
}
#Route to Internet
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.homelikevpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge({ Name = "rt-homelike-internet" }, var.tags)
}
#Route to Internet for Private IPS
resource "aws_route_table" "route_table_nat" {
  vpc_id = aws_vpc.homelikevpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags = merge({ Name = "rt-homelike-natgw" }, var.tags)
}
#Route Table Assoc
resource "aws_route_table_association" "route_assoc1" {
  subnet_id      = aws_subnet.alb["subnet-alb1"].id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "route_assoc2" {
  subnet_id      = aws_subnet.alb["subnet-alb2"].id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "route_assoc3" {
  subnet_id      = aws_subnet.alb["subnet-alb3"].id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "route_assoc_vpn" {
  subnet_id      = aws_subnet.vpn["vpn"].id
  route_table_id = aws_route_table.route_table.id
}
#-----------------------------------------------
resource "aws_route_table_association" "route_assoc4" {
  subnet_id      = aws_subnet.nginx["subnet-nginx1"].id
  route_table_id = aws_route_table.route_table_nat.id
}
resource "aws_route_table_association" "route_assoc5" {
  subnet_id      = aws_subnet.nginx["subnet-nginx2"].id
  route_table_id = aws_route_table.route_table_nat.id
}
resource "aws_route_table_association" "route_assoc6" {
  subnet_id      = aws_subnet.nginx["subnet-nginx3"].id
  route_table_id = aws_route_table.route_table_nat.id
}
#-----------------------------------------------
resource "aws_route_table_association" "route_assoc7" {
  subnet_id      = aws_subnet.app["subnet-app1"].id
  route_table_id = aws_route_table.route_table_nat.id
}
resource "aws_route_table_association" "route_assoc8" {
  subnet_id      = aws_subnet.app["subnet-app2"].id
  route_table_id = aws_route_table.route_table_nat.id
}
resource "aws_route_table_association" "route_assoc9" {
  subnet_id      = aws_subnet.app["subnet-app3"].id
  route_table_id = aws_route_table.route_table_nat.id
}
#-----------------------------------------------
resource "aws_route_table_association" "route_assoc10" {
  subnet_id      = aws_subnet.db["subnet-db1"].id
  route_table_id = aws_route_table.route_table_nat.id
}
resource "aws_route_table_association" "route_assoc11" {
  subnet_id      = aws_subnet.db["subnet-db2"].id
  route_table_id = aws_route_table.route_table_nat.id
}
resource "aws_route_table_association" "route_assoc12" {
  subnet_id      = aws_subnet.db["subnet-db3"].id
  route_table_id = aws_route_table.route_table_nat.id
}
#Security Groups
resource "aws_security_group" "alb_nginx" {
  name        = "alb_nginx"
  description = "HTTP from Internet"
  vpc_id      = aws_vpc.homelikevpc.id
  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #-----------------------------
  #for ansible server
  #----------------------------
  ingress {
    description = "SSH from Internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "nginx" {
  name        = "nginx"
  description = "HTTP from Internet"
  vpc_id      = aws_vpc.homelikevpc.id
  ingress {
    description = "HTTP from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.subnet_alb_details.subnet-alb1.cidr, var.subnet_alb_details.subnet-alb2.cidr, var.subnet_alb_details.subnet-alb3.cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #-----------------------------
  #for ansible server
  #----------------------------
  ingress {
    description = "SSH from Test ANSIBLE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_alb_details.subnet-alb1.cidr, var.subnet_alb_details.subnet-alb2.cidr, var.subnet_alb_details.subnet-alb3.cidr]
  }
}
resource "aws_security_group" "app" {
  name        = "app"
  description = "app"
  vpc_id      = aws_vpc.homelikevpc.id
  ingress {
    description = "Node JS from NGINX"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.subnet_nginx_details.subnet-nginx1.cidr, var.subnet_nginx_details.subnet-nginx2.cidr, var.subnet_nginx_details.subnet-nginx3.cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #-----------------------------
  #for ansible server
  #----------------------------
  ingress {
    description = "SSH from test ANSIBLE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_alb_details.subnet-alb1.cidr, var.subnet_alb_details.subnet-alb2.cidr, var.subnet_alb_details.subnet-alb3.cidr]
  }
}
resource "aws_security_group" "db" {
  name        = "db"
  description = "db"
  vpc_id      = aws_vpc.homelikevpc.id
  ingress {
    description = "ACCESS from APP SERVER"
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = [var.subnet_app_details.subnet-app1.cidr, var.subnet_app_details.subnet-app2.cidr, var.subnet_app_details.subnet-app3.cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #-----------------------------
  #SSH FROM VPN
  #----------------------------
  ingress {
    description = "SSH from VPN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_vpn_details.vpn.cidr]
  }
  #-----------------------------
  #for ansible server
  #----------------------------
  ingress {
    description = "SSH from test ANSIBLE"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.subnet_alb_details.subnet-alb1.cidr, var.subnet_alb_details.subnet-alb2.cidr, var.subnet_alb_details.subnet-alb3.cidr]
  }
}

resource "aws_security_group" "vpn" {
  name        = "vpn"
  description = "OPENVPN SEC GRP"
  vpc_id      = aws_vpc.homelikevpc.id
  ingress {
    description = "SSH from Office"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.office_ips]
  }
  ingress {
    description = "OPENVPN from Office"
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = [var.office_ips]
  }
  ingress {
    description = "HTTPS from Office"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.office_ips]
  }
  ingress {
    description = "OPENVPN from Office"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = [var.office_ips]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}