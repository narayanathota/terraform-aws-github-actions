variable "name_prefix" {
  description = "Prefix applied to every resource name"
  type        = string
}

variable "project_name" {
  description = "Short project identifier, baked into the landing page"
  type        = string
}

variable "environment" {
  description = "Deployment environment, baked into the landing page"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch the web server from"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet to launch the instance into"
  type        = string
}

variable "security_group_id" {
  description = "Security group to attach to the instance"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile to attach to the instance"
  type        = string
}

variable "bucket_name" {
  description = "Name of the application S3 bucket, passed to the landing page"
  type        = string
}
