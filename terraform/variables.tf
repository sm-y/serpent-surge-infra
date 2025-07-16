# serpent-surge-infra/terraform/variables.tf

variable "ami_id" {}
variable "subnet_id" {}
variable "security_group_ids" {
  type = list(string)
}
variable "key_name" {}
# variable "iam_instance_profile_name" {}
variable "aws_region" {
  type    = string
  default = "eu-north-1"
}
variable "db_username" {}
variable "db_password" {
  sensitive = true
}
