locals {

  metadata = {
    aws_region  = "us-east-1"
    environment = "Laboratory01"
    project        = "test"
    public_domain  = "gocloud.cloud"
    private_domain = "gocloud"

    key = {
      company = "gcl"
      region  = "use1"
      env     = "l01"
      project = "test"
    }
  }
  
  common_name_base = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_name = join("-", [
    local.common_name_base,
    local.metadata.key.project
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "created-by"  = "GoCloud.la"
  }
}
