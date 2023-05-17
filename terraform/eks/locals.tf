locals {
  aws_account_id = "005699609604"
  common = {
    tags = {
      "managed_by" = "terraform"
      "source"     = "https://github.com/TheSoftwareHouse/eks-demo"
      "owner"      = "The Software House"
    }
  }
}
