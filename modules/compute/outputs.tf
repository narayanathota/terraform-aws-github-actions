output "instance_id" {
  description = "ID of the web server instance"
  value       = aws_instance.web.id
}

output "elastic_ip" {
  description = "Elastic IP address of the web server"
  value       = aws_eip.web.public_ip
}

output "private_ip" {
  description = "Private IP of the web server"
  value       = aws_instance.web.private_ip
}
