variable "name" { type = string }
variable "tags" {
  type = map(string)
  default = {}
}
variable "image_tag_mutability" {
  type = string
  default = "MUTABLE"
}
variable "encryption_type" {
  type = string
  default = "AES256"
}
variable "set_policy" {
  type = bool
  default = false
}
variable "repository_policy_json" {
  type = string
  default = ""
}
