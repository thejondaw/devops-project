# ==================================================== #
# ==================== VPC Module ==================== #
# ==================================================== #

# "VPC" (Virtual Private Cloud):
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name        = "devops-project-vpc"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
  }
}

# ===================== Subnets ====================== #

# "Public Subnet #1" - "WEB":
resource "aws_subnet" "subnet_web" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_web_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"

  tags = {
    Name        = "subnet-web"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "public"
    Tier        = "web"
  }
}

# "Public Subnet #2" - "ALB" (Application Load Balancer):
resource "aws_subnet" "subnet_alb" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_alb_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"

  tags = {
    Name        = "subnet-alb"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "public"
    Tier        = "alb"
  }
}

# "Private Subnet #3" - "API":
resource "aws_subnet" "subnet_api" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_api_cidr
  availability_zone = "us-east-2a"

  tags = {
    Name        = "subnet-api"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "private"
    Tier        = "api"
  }
}

# "Private Subnet #4" - "Database" (DB):
resource "aws_subnet" "subnet_db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_db_cidr
  availability_zone = "us-east-2c"

  tags = {
    Name        = "subnet-db"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "private"
    Tier        = "database"
  }
}

# ========= Internet Gateway and Route Table ========= #

# "Internet Gateway" (IGW):
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "devops-project-igw"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
  }
}

# "Route Table" - Attach "IGW" to "Public Subnets":
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "devops-project-public-rt"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "public"
  }
}
# Association of "Public Subnet #1 (WEB)" with "Route Table":
resource "aws_route_table_association" "public_web" {
  subnet_id      = aws_subnet.subnet_web.id
  route_table_id = aws_route_table.public_rt.id
}

# Association of "Public Subnet #2 (ALB)" with "Route Table":
resource "aws_route_table_association" "public_alb" {
  subnet_id      = aws_subnet.subnet_alb.id
  route_table_id = aws_route_table.public_rt.id
}

# =========== NAT Gateway and Route Table ============ #

# "Elastic IP" for "NAT Gateway":
resource "aws_eip" "project-eip" {
  domain = "vpc"
}

# "NAT Gateway":
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.project-eip.id
  subnet_id     = aws_subnet.subnet_web.id

  tags = {
    Name        = "devops-project-nat"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
  }
}

# "Route Table" for "Private Subnets":
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "devops-project-private-rt"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "private"
  }
}

# Route for "NAT Gateway" to "Private Subnets":
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

# Association of "Private Subnet #3 (API)" with "Route Table":
resource "aws_route_table_association" "Private_1" {
  subnet_id      = aws_subnet.subnet_api.id
  route_table_id = aws_route_table.private_rt.id
}

# Association of "Private Subnet #4 (DB)" with "Route Table":
resource "aws_route_table_association" "Private_2" {
  subnet_id      = aws_subnet.subnet_db.id
  route_table_id = aws_route_table.private_rt.id
}

# ==================================================== #

# "Security Group" - Allow connect to "HTTP" and "SSH":
resource "aws_security_group" "sec_group_vpc" {
  name        = "sec-group-vpc"
  description = "Allow incoming HTTP Connections"
  vpc_id      = aws_vpc.main.id

  # HTTP:
  ingress {
    description = "Allow incoming HTTP for redirect to HTTPS"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS:
  ingress {
    description = "Allow incoming HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH:
  ingress {
    description = "Allow SSH from only our VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all "Outbound Traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "devops-project-vpc-sg"
    Environment = var.environment
    Project     = "devops-project"
    ManagedBy   = "terraform"
    Type        = "vpc-security"
  }
}

# ==================================================== #
