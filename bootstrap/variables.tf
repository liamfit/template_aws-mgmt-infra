variable "region" {
  type    = string
  default = ""
}

variable "org" {
  type    = string
  default = "liamfit"
}

variable "infra_prefix" {
  type = string
}

variable "dynamodb_table" {
  type    = string
  default = "terraform-state"
}

variable "github_role_name" {
  type    = string
}

variable "accounts" {
  type = map(any)
}

variable "default_tags" {
  type = map(any)
}