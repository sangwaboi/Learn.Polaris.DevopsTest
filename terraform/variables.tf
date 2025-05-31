variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "flask-app-key"
}

variable "public_key" {
  description = "Public key content for SSH access"
  type        = string
  # You need to provide this value when running terraform
  # Example: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ...
}

variable "github_repo" {
  description = "GitHub repository in format 'username/repository'"
  type        = string
  # Example: "yourusername/flask-cicd-project"
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "flask-cicd"
} 