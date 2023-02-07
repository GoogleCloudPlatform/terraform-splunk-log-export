terraform {
  required_version = ">= 0.14.4"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 3.54.0"
    }
  }
}
