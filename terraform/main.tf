terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
  required_version = ">= 0.14"
}

data "archive_file" "main" {
  type = "zip"
  source {
    filename = "main.tf"
    content  = file("${path.module}/main.tf")
  }
  output_path = "${path.module}/main.zip"
}
