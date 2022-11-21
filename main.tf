 provider "aws" {
    region = "us-east-1"
    shared_config_files      = ["./config/conf"]
 }

resource "aws_cloudwatch_log_group" "Glue_logs" {
   name = "Glue_logs"
   retention_in_days = 3
}

resource "aws_s3_bucket" "glue" {
   bucket = "avi.ravipati.gluescripts"
}

resource "aws_glue_job" "test_py_job" {
   name = "test_py_job"
   max_capacity = 0.0625
   #max_retries = 2
   role_arn = "arn:aws:iam::751271771288:role/terraform_glue_role"

   command {
     name = "pythonshell"
     script_location = "S3://${aws_s3_bucket.glue.bucket}/hello_world.py"
     python_version = 3

   }

}

#resource "aws_glue_trigger" "test_py_job_trigger" {
#   name = "test_py_job_trigger"
#   schedule = "cron(20 3 20 11 * 2022)"
#   type = "SCHEDULED"
#   actions {
#     job_name=test_py_job
#   }
#}