output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.flask_server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_eip.flask_eip.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.flask_server.public_dns
}

output "application_url" {
  description = "URL to access the Flask application"
  value       = "http://${aws_eip.flask_eip.public_ip}"
}

output "ssh_connection_command" {
  description = "Command to SSH into the instance"
  value       = "ssh -i ~/.ssh/${var.key_name} ubuntu@${aws_eip.flask_eip.public_ip}"
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.flask_vpc.id
}

output "subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.flask_public_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.flask_sg.id
}

output "key_pair_name" {
  description = "Name of the key pair"
  value       = aws_key_pair.flask_key.key_name
} 