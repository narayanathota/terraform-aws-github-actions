variable "name_prefix" {
  description = "Prefix applied to every resource name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "AZs to place the public subnets in"
  type        = list(string)
}

variable "ssh_allowed_cidr" {
  description = "CIDR permitted on port 22; empty disables SSH ingress"
  type        = string
  default     = ""
}
