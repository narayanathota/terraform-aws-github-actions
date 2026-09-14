data "aws_availability_zones" "available" {
  state = "available"
}

# Latest Amazon Linux 2023 AMI, published by AWS as an SSM parameter.
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  ami_id      = var.ami_id != "" ? var.ami_id : data.aws_ssm_parameter.al2023.value
  azs = slice(data.aws_availability_zones.available.names, 0,
  length(var.public_subnet_cidrs))
}

module "networking" {
  source = "./modules/networking"

  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  availability_zones  = local.azs
  ssh_allowed_cidr    = var.ssh_allowed_cidr
}

module "compute" {
  source = "./modules/compute"

  name_prefix           = local.name_prefix
  project_name          = var.project_name
  environment           = var.environment
  ami_id                = local.ami_id
  instance_type         = var.instance_type
  subnet_id             = module.networking.public_subnet_ids[0]
  security_group_id     = module.networking.web_security_group_id
  instance_profile_name = aws_iam_instance_profile.ec2.name
  bucket_name           = aws_s3_bucket.app.bucket
}
