terraform {
  required_version = ">= 1.9"
}

module "service" {
  source    = "../../modules/service"
  env       = "prod"
  replicas  = 3
  log_level = "warn"
}
