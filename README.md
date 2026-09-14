# Project 03 — AWS Infrastructure Automation with Terraform & GitHub Actions

Provisions AWS infrastructure with Terraform, applied automatically through
a GitHub Actions pipeline that pauses for manual approval before touching
anything in AWS.

## Overview

```
GitHub push → GitHub Actions (fmt → init → validate → plan → upload artifact)
            → manual approval
            → apply → outputs → validation
            → VPC + EC2 (Nginx) + Elastic IP + S3, all live in AWS
```

## Repository structure

```
terraform-aws-github-actions/
├── .github/workflows/terraform.yml   CI/CD pipeline
├── modules/
│   ├── networking/                   VPC, subnets, IGW, route table, SG
│   └── compute/                      EC2, EIP, user-data web server
├── docs/screenshots/                 evidence for submission
├── versions.tf / backend.tf          providers + remote state config
├── variables.tf / terraform.tfvars   configurable inputs
├── main.tf                           wires the two modules together
├── s3.tf / iam.tf                    app bucket + EC2 role
└── outputs.tf                        deployment outputs
```

## Prerequisites

- Terraform >= 1.10
- AWS CLI (or AWS CloudShell)
- An AWS account
- A GitHub OIDC role trusted for this repo (see below) — no stored AWS secrets

## One-time bootstrap (run in AWS CloudShell)

```bash
REGION=ap-south-1
BUCKET=REPLACE-WITH-YOUR-STATE-BUCKET-NAME

aws s3api create-bucket \
  --bucket "$BUCKET" --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

Paste the resulting bucket name into `backend.tf`.

## Input variables

| Name | Description | Default |
|---|---|---|
| `aws_region` | AWS region to deploy into | `ap-south-1` |
| `project_name` | Short project identifier used in resource names | `project03` |
| `environment` | Deployment environment | `dev` |
| `vpc_cidr` | CIDR block for the VPC | `10.0.0.0/16` |
| `public_subnet_cidrs` | CIDR blocks for the public subnets | `["10.0.1.0/24","10.0.2.0/24"]` |
| `instance_type` | EC2 instance type | `t3.micro` |
| `ami_id` | AMI override; empty = latest Amazon Linux 2023 | `""` |
| `ssh_allowed_cidr` | CIDR allowed on port 22; empty = no SSH rule | `""` |

## Outputs

| Name | Description |
|---|---|
| `vpc_id` | ID of the provisioned VPC |
| `public_subnet_ids` | IDs of the two public subnets |
| `security_group_id` | ID of the web security group |
| `ec2_instance_id` | ID of the web server instance |
| `elastic_ip` | Elastic IP attached to the web server |
| `application_url` | Public URL of the landing page |
| `s3_bucket_name` | Name of the application S3 bucket |
| `iam_role_name` | Name of the EC2 IAM role |
| `iam_instance_profile_name` | Name of the EC2 instance profile |

## CI/CD pipeline

`.github/workflows/terraform.yml` runs on every push to `main`: checkout →
format check → init → validate → plan → upload plan artifact → **stop for
manual approval** (GitHub Environment `production`, required reviewer) →
apply → print outputs → validate the live infrastructure end to end,
including curling the Elastic IP until the web server answers.

Authentication uses **GitHub OIDC**, not a stored AWS key: the workflow
assumes an IAM role trusted only for this exact repository. No
`AWS_ACCESS_KEY_ID` or secret exists anywhere in this repo or its settings.

## Security notes

- No hardcoded credentials anywhere — GitHub Actions authenticates via OIDC
- EC2 attached to a Terraform-created, least-privilege role: read/write on
  only its own S3 bucket, plus SSM (so port 22 stays closed by default)
- IMDSv2 required on the instance; root volume encrypted
- S3 bucket: versioning + AES-256 encryption + all public access blocked
- Terraform state lives in S3, is encrypted, and is never committed to git
- EC2 instance type and volume size are held within this AWS account's
  policy limits (t2/t3 micro–large, ≤100GB gp2/gp3)

## Cleanup

```bash
terraform destroy
```

Then empty and delete the state bucket (it's versioned, so `delete-object`
on every version, or delete via the console).
