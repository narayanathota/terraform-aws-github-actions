output "vpc_id" {
  description = "ID of the provisioned VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets"
  value       = module.networking.public_subnet_ids
}

output "security_group_id" {
  description = "ID of the web security group"
  value       = module.networking.web_security_group_id
}

output "ec2_instance_id" {
  description = "ID of the web server instance"
  value       = module.compute.instance_id
}

output "elastic_ip" {
  description = "Elastic IP attached to the web server"
  value       = module.compute.elastic_ip
}

output "application_url" {
  description = "Public URL of the landing page"
  value       = "http://${module.compute.elastic_ip}"
}

output "s3_bucket_name" {
  description = "Name of the application S3 bucket"
  value       = aws_s3_bucket.app.bucket
}

output "iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = aws_iam_role.ec2.name
}

output "iam_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2.name
}
