 provider "aws" {
    region = "us-east-1"
 }

resource "aws_s3_bucket" "glue" {
   bucket = "avi.ravipati.gluescripts"
}

resource "aws_cloudwatch_log_group" "output" {
  name = "/aws-glue/python-jobs/output"
  retention_in_days = 7
}
resource "aws_cloudwatch_log_group" "error" {
  name = "/aws-glue/python-jobs/error"
  retention_in_days = 7
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
            Effect: "Allow",
            Action: [
                "logs:DeleteDataProtectionPolicy",
                "logs:DeleteSubscriptionFilter",
                "logs:DeleteLogStream",
                "logs:CreateExportTask",
                "logs:CreateLogStream",
                "logs:DeleteMetricFilter",
                "S3:*",
                "logs:CancelExportTask",
                "logs:DeleteRetentionPolicy",
                "logs:DeleteLogDelivery",
                "logs:AssociateKmsKey",
                "logs:PutDestination",
                "logs:DisassociateKmsKey",
                "logs:PutDataProtectionPolicy",
                "logs:DeleteLogGroup",
                "logs:PutDestinationPolicy",
                "logs:DeleteQueryDefinition",
                "logs:PutQueryDefinition",
                "logs:DeleteDestination",
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:Link",
                "logs:PutMetricFilter",
                "logs:CreateLogDelivery",
                "logs:UpdateLogDelivery",
                "logs:PutSubscriptionFilter",
                "logs:PutRetentionPolicy"
            ],
            "Resource": [
               "*"
            ]
      }
    ]
  })

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
   default_arguments = {
    # ... potentially other arguments ...
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-continuous-log-filter"     = "true"
    "--enable-metrics"                   = ""
  }
}
