 provider "aws" {
    region = "us-east-1"
 }

resource "aws_iam_role" "terraform_glue_role" {
  name = "terraform_glue_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal: {
           Service: "glue.amazonaws.com"
            },
        Action: "sts:AssumeRole"
      },
    ]
  })

}

resource "aws_iam_role_policy" "terraform_glue_role_policy" {
  name = "terraform_glue_role_policy"
  role = aws_iam_role.terraform_glue_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "S3:*",
          "CloudWatch:*"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_s3_bucket" "glue" {
   bucket = "avi.ravipati.gluescripts"
}

resource "aws_glue_job" "test_py_job" {
   name = "test_py_job"
   max_capacity = 0.0625
   #max_retries = 2
   role_arn = aws_iam_role.terraform_glue_role.arn
   command {
     name = "pythonshell"
     script_location = "S3://${aws_s3_bucket.glue.bucket}/hello_world.py"
     python_version = 3
   }
}
