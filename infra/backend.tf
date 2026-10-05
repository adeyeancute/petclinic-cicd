# Uncomment and fill in once you've created an S3 bucket (+ optionally a
# DynamoDB table for state locking) to store Terraform state remotely.
#
# terraform {
#   backend "s3" {
#     bucket       = "petclinic-terraform-state"
#     key          = "petclinic/terraform.tfstate"
#     region       = "us-east-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }
