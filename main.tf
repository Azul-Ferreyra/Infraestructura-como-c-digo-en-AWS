############# PROVIDER ################
provider "aws" {
  region  = "eu-north-1"          
  profile = "tu-perfil-aws"
  
}

############# DATA SOURCES ################
data "aws_availability_zones" "available" {}

############# VPC ################
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

############# VPC ENDPOINTS (SSM) ################
############# El servidor no tiene que salir a internet para ser administrado.

# Security Group para los Endpoints de SSM
resource "aws_security_group" "ssm_endpoints_sg" {
  name        = "ssm-endpoints-sg"
  description = "Permitir trafico HTTPS hacia los endpoints de SSM"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id, aws_security_group.wazuh_sg.id]
  }

  tags = { Name = "ssm-endpoints-sg" }
}

#Endpoint para el servicio SSM
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.eu-north-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  security_group_ids  = [aws_security_group.ssm_endpoints_sg.id]
  private_dns_enabled = true
}

#Endpoint para SSM Messages
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.eu-north-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  security_group_ids  = [aws_security_group.ssm_endpoints_sg.id]
  private_dns_enabled = true
}

# Endpoint para EC2 Messages
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.main_vpc.id
  service_name        = "com.amazonaws.eu-north-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
  security_group_ids  = [aws_security_group.ssm_endpoints_sg.id]
  private_dns_enabled = true
}


############# SUBNETS ################
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "public-subnet-nginx"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "private-subnet"
  }
}

############# INTERNET GATEWAY ################
resource "aws_internet_gateway""igw" {
  vpc_id = aws_vpc.main_vpc.id
}

############# ROUTE TABLES ################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

########################################### NAT GATEWAY ###########################################
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.nat.id
}


############# SECURITY GROUPS ################
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg"
  description = "Ingreso 443 desde cualquier parte"
  vpc_id      = aws_vpc.main_vpc.id


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "nginx-sg" }
}

resource "aws_security_group" "wazuh_sg" {
  name        = "wazuh-sg"
  description = "Ingreso 443 desde Nginx"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]
    description     = "HTTPS ingresa Nginx"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "wazuh-sg" }
}

############# INSTANCIA NGINX ################
resource "aws_instance" "nginx_server" {
  depends_on = [aws_instance.wazuh_server]  # Forzamos la creación del Wazuh antes de Nginx

  ami                    = var.nginx_ami   # Ubuntu 22.04 
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile   = "SSM-WAZUH"
   
user_data = <<-EOF
  #!/bin/bash
  set -e
  export DEBIAN_FRONTEND=noninteractive
  apt update -y
  apt install -y nginx
  systemctl enable nginx
  systemctl start nginx
EOF
  tags = {
    Name = "nginx-server"
  }
}

############# INSTANCIA WAZUH ################
resource "aws_instance" "wazuh_server" {
  ami = var.wazuh_ami   # Ubuntu 24.04 
  instance_type          = "t3.xlarge"
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.wazuh_sg.id]
  iam_instance_profile   = "SSM-WAZUH"

  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    delete_on_termination = true
  }
############ Ejemplo de instalacion de Wazuh Manager ################
user_data = <<-EOF
  #!/bin/bash
  set -e
  export DEBIAN_FRONTEND=noninteractive
  apt update -y
  apt install -y curl apt-transport-https unzip gnupg
  curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/wazuh-archive-keyring.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list

  apt update -y
  apt install -y wazuh-manager     ### Esto es solo un ejemplo, hace falta instalar Wazuh Dashboard y Wazuh Indexer para que funcione todo completo ###
  systemctl enable wazuh-manager
  systemctl start wazuh-manager          
EOF
  tags = { Name = "wazuh-server" }
}

############# OUTPUTS ################
output "nginx_public_ip" {
  description = "Dirección IP pública del servidor Nginx (proxy reverso)"
  value       = aws_instance.nginx_server.public_ip
}

output "wazuh_private_ip" {
  description = "Dirección IP privada del servidor Wazuh"
  value       = aws_instance.wazuh_server.private_ip
}

############# VARIABLES ################
variable "nginx_ami" {
  description = "AMI personalizada para Nginx"
  type        = string
  default     = "ami-020b2e0a92ce1206a" # Selecciona una AMI Ubuntu 24.04 LTS
}

variable "wazuh_ami" {
  description = "AMI personalizada para Wazuh"
  type        = string
  default     = "ami-0eb5867ca70cc16bb" # Selecciona una AMI Ubuntu 24.04 LTS
}



############# Gracias por ver mi lab, espero que te sea útil! ################ ferreyra Azul R. Anzur 12/11/2025 ############################
