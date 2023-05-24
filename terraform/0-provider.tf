terraform {

  backend "s3" {
    bucket = "terraform-state-webexsdk-webhook-handler"
    key = "global/s3/terraform.tfstate"
    region =  "us-east-1"
    dynamodb_table =  "terraform-state-locking-webexsdk-webhook-handler"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version =  "~> 4.21.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region #"us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-webexsdk-webhook-handler"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking-webexsdk-webhook-handler"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
