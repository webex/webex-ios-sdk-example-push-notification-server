# These variable are defined in terraform.tfvars file

variable "aws_region" {
  description = "The root domain name for API gateway"
  default = "us-east-1"
}

variable "apns_team_id" {
  description = "APNS team id"
}

variable "apns_token_key_id" {
  description = "APNS token key id"
}

variable "apns_token_key" {
  description = "APNS token key"
}

variable "apns_bundle_id" {
  description = "APNS bundle id"
}

variable "fcm_api_key" {
  description = "FCM API key"
}

variable "root_domain_name" {
  description = "The root domain name for API gateway"
}

variable "domain_name" {
  description = "The FQDN for API gateway"
}
