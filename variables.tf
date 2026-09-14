variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Short project identifier used in resource names"
  type        = string
  default     = "project03"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets, one per AZ"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnets are required."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the web server. Leave empty to use the latest Amazon Linux 2023 AMI."
  type        = string
  default     = ""
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitted to reach port 22. Empty means no SSH ingress rule is created."
  type        = string
  default     = ""
}
