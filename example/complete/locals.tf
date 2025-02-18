locals {

  metadata = {
    aws_region  = "us-east-1"
    environment = "Laboratory01"

    public_domain  = "gocloud.cloud"
    private_domain = "gocloud"

    key = {
      company = "gcl"
      region  = "use1"
      env     = "l01"
    }
  }

  common_name = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "created-by"  = "GoCloud.la"
  }
}
