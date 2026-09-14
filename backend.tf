# FILL IN: replace with the bucket name you create in Phase 02
# (in AWS CloudShell). Backend blocks cannot use variables, so this
# has to be a literal string. It is not a secret — safe to commit.
terraform {
  backend "s3" {
    bucket       = "tfstate-sandeep-project03-9174"
    key          = "project-03/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
