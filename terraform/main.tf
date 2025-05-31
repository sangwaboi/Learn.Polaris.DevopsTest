# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Data source to get the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Create a VPC
resource "aws_vpc" "flask_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "flask-app-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "flask_igw" {
  vpc_id = aws_vpc.flask_vpc.id

  tags = {
    Name = "flask-app-igw"
  }
}

# Create a public subnet
resource "aws_subnet" "flask_public_subnet" {
  vpc_id                  = aws_vpc.flask_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "flask-app-public-subnet"
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Create a route table
resource "aws_route_table" "flask_public_rt" {
  vpc_id = aws_vpc.flask_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flask_igw.id
  }

  tags = {
    Name = "flask-app-public-rt"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "flask_public_rta" {
  subnet_id      = aws_subnet.flask_public_subnet.id
  route_table_id = aws_route_table.flask_public_rt.id
}

# Create a security group
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Security group for Flask application"
  vpc_id      = aws_vpc.flask_vpc.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask-app-sg"
  }
}

# Create a key pair
resource "aws_key_pair" "flask_key" {
  key_name   = var.key_name
  public_key = var.public_key
}

# User data script to install Docker and setup the application
locals {
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

    # Install Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io

    # Start and enable Docker
    systemctl start docker
    systemctl enable docker

    # Add ubuntu user to docker group
    usermod -aG docker ubuntu

    # Create application directory
    mkdir -p /home/ubuntu/flask-app
    chown ubuntu:ubuntu /home/ubuntu/flask-app

    # Create a simple startup script
    cat > /home/ubuntu/start-app.sh << 'EOL'
#!/bin/bash
cd /home/ubuntu/flask-app
if [ -d ".git" ]; then
    git pull origin main
else
    git clone https://github.com/${var.github_repo}.git .
fi
docker build -t flask-app .
docker stop flask-app || true
docker rm flask-app || true
docker run -d -p 80:5000 --name flask-app --restart unless-stopped flask-app
EOL

    chmod +x /home/ubuntu/start-app.sh
    chown ubuntu:ubuntu /home/ubuntu/start-app.sh

    # Install GitHub CLI (optional, for easier repo management)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    apt update
    apt install gh -y

    # Signal that the instance is ready
    echo "Flask app server setup complete" > /home/ubuntu/setup-complete.txt
    chown ubuntu:ubuntu /home/ubuntu/setup-complete.txt
  EOF
}

# Create the EC2 instance
resource "aws_instance" "flask_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.flask_key.key_name
  vpc_security_group_ids = [aws_security_group.flask_sg.id]
  subnet_id              = aws_subnet.flask_public_subnet.id
  user_data              = base64encode(local.user_data)

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = "flask-app-server"
    Type = "web-server"
  }
}

# Create an Elastic IP
resource "aws_eip" "flask_eip" {
  instance = aws_instance.flask_server.id
  domain   = "vpc"

  tags = {
    Name = "flask-app-eip"
  }

  depends_on = [aws_internet_gateway.flask_igw]
} 