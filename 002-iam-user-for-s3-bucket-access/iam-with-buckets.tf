terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

resource "random_string" "bucket_suffix" {
  length  = 16
  special = false
  upper   = false
}

variable "aws_profile" {
  type = string
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
}

resource "aws_s3_bucket" "catpics" {
  bucket = "catpics-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket" "animalpics" {
  bucket = "animalpics-${random_string.bucket_suffix.result}"
}

resource "aws_iam_user" "sally" {
  name = "sally"
}

resource "aws_iam_user_login_profile" "sally_login_profile" {
  user                    = aws_iam_user.sally.name
  password_reset_required = true
}

resource "aws_iam_policy" "allow_all_s3_except_cats" {
  name   = "allow_all_s3_except_cats"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "*"
      },
      {
        Effect   = "Deny"
        Action   = "s3:*"
        Resource = "${aws_s3_bucket.catpics.arn}/*"
      }
    ]
  })
}

# We don't actually want to attach the policy as part of the deployment,
# but here's how it would look like if we do:
#resource "aws_iam_user_policy_attachment" "sally_allow_all_s3_except_cats" {
#  user       = aws_iam_user.sally.name
#  policy_arn = aws_iam_policy.allow_all_s3_except_cats.arn
#}

resource "aws_iam_user_policy_attachment" "sally_change_password" {
  user       = aws_iam_user.sally.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

output "catpicsbucketname" {
  value = aws_s3_bucket.catpics.id
}

output "animalsbucketname" {
  value = aws_s3_bucket.animalpics.id
}

output "sallyusername" {
  value = aws_iam_user.sally.name
}

# There's no straightforward way to set the password to
# an IAM user, so we'll just output the unencrypted password.
output "sallypassword" {
  value = aws_iam_user_login_profile.sally_login_profile.password
}
