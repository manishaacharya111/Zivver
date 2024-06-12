terraform {
  backend "s3" {
    bucket         = "zivver-terraform-s3-bucket" # Provide the actual S3 bucket name created in console
    key            = "zivver/ecs/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "dynamodb-state-locking-ecs"
  }
}
