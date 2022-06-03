provider "aws" {
  region     = "eu-west-1"
  shared_credentials_files = ["~/.aws/credentials"]
}

terraform {
  backend "s3" {
    bucket         = "orangutan-terraform-state" //s3 bucket name
    key            = "global/s3/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "orangutan-terraform-state-locks" //LockID (String) will be the only dynamoDB table ID
    encrypt        = true
    profile = "default" // configure profile using aws configure command otherwise the backend will not work
  }
}
