# The EC2 web server's own role — created here by Terraform. Scoped to
# read/write only its own S3 bucket, plus SSM so we never need to open
# port 22 to reach the instance.

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${local.name_prefix}-ec2-role"
  description        = "Role assumed by the project web server"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "app_bucket_access" {
  statement {
    sid       = "ListOnlyThisBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.app.arn]
  }

  statement {
    sid       = "ReadWriteObjectsInThisBucket"
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.app.arn}/*"]
  }
}

resource "aws_iam_role_policy" "app_bucket_access" {
  name   = "${local.name_prefix}-s3-access"
  role   = aws_iam_role.ec2.id
  policy = data.aws_iam_policy_document.app_bucket_access.json
}

# Lets you reach the instance with Session Manager instead of opening port 22.
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}
