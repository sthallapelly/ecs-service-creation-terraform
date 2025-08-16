variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "cluster_arn" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_ids" {
  type = list(string)
}

# Path to JSON file which contains a map of services
variable "services_file" {
  type    = string
  default = "examples/services.json"
}

# Optional global roles
variable "execution_role_arn" {
  type    = string
  default = ""
}
variable "task_role_arn" {
  type    = string
  default = ""
}

# ALB listener ARN to attach rules (one listener used for all services)
variable "listener_arn" {
  type    = string
  default = ""
}
