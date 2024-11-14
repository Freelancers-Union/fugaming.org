terraform {
  backend "s3" {
    bucket         = "fubot-tfstate"
    dynamodb_table = "terraform-state"
    key            = "production/fugaming-org/terraform.tfstate"
    region         = "eu-west-1"
  }
}
