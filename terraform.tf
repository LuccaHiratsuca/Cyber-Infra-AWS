#-----------------------------
# Provider Configuration
#-----------------------------
provider "aws" {
  region = "us-east-2"
}

#-----------------------------
# VPC Configuration
#-----------------------------
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "CibersecGrupo3"
  }
}

#-----------------------------
# Subnets
#-----------------------------
# Jump Server Subnet in us-east-2a
resource "aws_subnet" "jump_server_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "JumpServerSubnet"
  }
}

# Dev Subnet in us-east-2b
resource "aws_subnet" "dev_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "DevSubnet"
  }
}

# DB Subnet in us-east-2a
resource "aws_subnet" "db_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = false  # DB subnet is private

  tags = {
    Name = "DbSubnet"
  }
}

#-----------------------------
# Internet Gateway and Route Tables
#-----------------------------
# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "MainInternetGateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "jump_server_subnet_association" {
  subnet_id      = aws_subnet.jump_server_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "dev_subnet_association" {
  subnet_id      = aws_subnet.dev_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Route Table for Private Subnets (DB Subnet)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associate Route Table with DB Subnet
resource "aws_route_table_association" "db_subnet_association" {
  subnet_id      = aws_subnet.db_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

#-----------------------------
# Security Groups
#-----------------------------
# Jump Server Security Group
resource "aws_security_group" "jump_server_sg" {
  name        = "JumpServerSG"
  description = "Security group for Jump Server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["189.110.124.24/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "JumpServerSG"
  }
}

# Wazuh Server Security Group
resource "aws_security_group" "wazuh_sg" {
  name        = "SG-Wazuh"
  description = "Security group for Wazuh Server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "SSH from Jump Server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jump_server_sg.id]
  }

  ingress {
    description = "Wazuh Agent communication TCP"
    from_port   = 1514
    to_port     = 1514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh Agent communication UDP"
    from_port   = 1514
    to_port     = 1514
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Wazuh API"
    from_port   = 55000
    to_port     = 55000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-Wazuh"
  }
}

# Zabbix Server Security Group
resource "aws_security_group" "zabbix_sg" {
  name        = "ZabbixSG"
  description = "Security group for Zabbix Server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "SSH from Jump Server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jump_server_sg.id]
  }

  ingress {
    description = "Zabbix Agent"
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Zabbix Server"
    from_port   = 10051
    to_port     = 10051
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ZabbixSG"
  }
}

# FastAPI Server Security Group
resource "aws_security_group" "fastapi_sg" {
  name        = "SG-FastAPI"
  description = "Security group for FastAPI Server"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "SSH from Jump Server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jump_server_sg.id]
  }

  ingress {
    description = "FastAPI Application"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-FastAPI"
  }
}

# Database Security Group for RDS
resource "aws_security_group" "db_sg" {
  name        = "DbSG"
  description = "Security group for RDS Database"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "MySQL from FastAPI Server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [
      aws_security_group.fastapi_sg.id,
      aws_security_group.jump_server_sg.id
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DbSG"
  }
}

#-----------------------------
# Key Pair
#-----------------------------
resource "aws_key_pair" "main_key" {
  key_name   = "ASIATQPD7JFZ5AMMD6V7"
  public_key = file(".aws/credentials")
}

#-----------------------------
# EC2 Instances
#-----------------------------
# Jump Server Instance (Updated)
resource "aws_instance" "jump_server" {
  ami                    = "ami-0ea3c35c5c3284d82"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.jump_server_subnet.id
  vpc_security_group_ids = [aws_security_group.jump_server_sg.id]
  key_name               = aws_key_pair.main_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              yum update -y
              # Install necessary tools
              yum install -y telnet nc mysql
              EOF

  tags = {
    Name = "Jump-Server"
  }
}

# Wazuh Server Instance
resource "aws_instance" "wazuh_server" {
  ami                    = "ami-0ea3c35c5c3284d82"
  instance_type          = "t3.medium"
  subnet_id              = aws_subnet.jump_server_subnet.id
  vpc_security_group_ids = [aws_security_group.wazuh_sg.id]
  key_name               = aws_key_pair.main_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install Wazuh repository GPG key
              rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
              # Install Wazuh repository
              cat > /etc/yum.repos.d/wazuh.repo << EOM
              [wazuh]
              name=Wazuh repository
              baseurl=https://packages.wazuh.com/4.x/yum/
              enabled=1
              gpgcheck=1
              gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
              EOM
              # Install Wazuh manager
              yum install wazuh-manager -y
              systemctl enable wazuh-manager
              systemctl start wazuh-manager
              EOF

  tags = {
    Name = "Wazuh"
  }
}

# Zabbix Server Instance
resource "aws_instance" "zabbix_server" {
  ami                    = "ami-0ea3c35c5c3284d82"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.db_subnet.id
  vpc_security_group_ids = [aws_security_group.zabbix_sg.id]
  key_name               = aws_key_pair.main_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Install Zabbix repository
              rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
              yum clean all
              # Install Zabbix server and agent
              yum install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent
              # Start Zabbix server
              systemctl enable zabbix-server
              systemctl start zabbix-server
              EOF

  tags = {
    Name = "Zabbix-Server"
  }
}

# FastAPI Server Instance (Updated)
resource "aws_instance" "fastapi_server" {
  ami                    = "ami-0ea3c35c5c3284d82"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.dev_subnet.id
  vpc_security_group_ids = [aws_security_group.fastapi_sg.id]
  key_name               = aws_key_pair.main_key.key_name

  # Use a template file for user_data to inject variables
  user_data = data.template_file.fastapi_user_data.rendered

  tags = {
    Name = "FastAPI-Dev-Server"
  }
}

# Template File for FastAPI User Data
data "template_file" "fastapi_user_data" {
  template = file("fastapi_user_data.sh")

  vars = {
    db_endpoint = aws_db_instance.fastapi_db.address
    db_username = "dev"
    db_password = "senha_forte"
    db_name     = "fastapi-db"
  }
}

#-----------------------------
# RDS MySQL Instance
#-----------------------------
# Subnet Group for RDS
resource "aws_db_subnet_group" "fastapi_db_subnet_group" {
  name       = "fastapi-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet.id]

  tags = {
    Name = "fastapi-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "fastapi_db" {
  identifier              = "fastapi-db"
  engine                  = "mysql"
  engine_version          = "8.0.33"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = "dev"
  password                = "senha_forte"
  db_name                 = "your_db_name"
  db_subnet_group_name    = aws_db_subnet_group.fastapi_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  publicly_accessible     = false
  skip_final_snapshot     = true
  multi_az                = false
  availability_zone       = "us-east-2a"

  tags = {
    Name = "fastapi-db"
  }
}

#-----------------------------
# Outputs
#-----------------------------
output "jump_server_public_ip" {
  value = aws_instance.jump_server.public_ip
}

output "wazuh_server_public_ip" {
  value = aws_instance.wazuh_server.public_ip
}

output "zabbix_server_private_ip" {
  value = aws_instance.zabbix_server.private_ip
}

output "fastapi_server_public_ip" {
  value = aws_instance.fastapi_server.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.fastapi_db.endpoint
}
