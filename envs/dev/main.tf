terraform {
  required_version = ">= 1.9"
}

module "service" {
  source    = "../../modules/service"
  env       = "dev"
  replicas  = 1
  log_level = "debug"
}
