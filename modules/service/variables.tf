variable "service_name" { type = string }
variable "cluster_arn" { type = string }
variable "task_definition_arn" { type = string }

variable "desired_count" {
  type    = number
  default = 0
}
variable "container_name" { type = string }
variable "container_port" { type = number }
variable "platform_version" {
  type    = string
  default = "LATEST"
}
variable "deployment_controller_type" {
  type    = string
  default = "ECS"
}

variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_ids" { type = list(string) }
variable "assign_public_ip" {
  type    = bool
  default = false
}

variable "create_load_balancer" {
  type    = bool
  default = true
}
variable "tg_name" { type = string }
variable "tg_port" {
  type    = number
  default = 80
}
variable "tg_protocol" {
  type    = string
  default = "HTTP"
}

variable "health_check_path" {
  type    = string
  default = "/"
}
variable "health_check_protocol" {
  type    = string
  default = "HTTP"
}
variable "health_check_matcher" {
  type    = string
  default = "200"
}
variable "health_check_interval" {
  type    = number
  default = 30
}
variable "health_check_timeout" {
  type    = number
  default = 5
}
variable "health_check_healthy_threshold" {
  type    = number
  default = 2
}
variable "health_check_unhealthy_threshold" {
  type    = number
  default = 2
}

variable "create_listener_rule" {
  type    = bool
  default = true
}
variable "listener_arn" {
  type    = string
  default = ""
}
variable "listener_rule_priority" {
  type    = number
  default = 100
}
variable "rule_path_patterns" {
  type = list(string)
  default = ["/*"]
}
variable "rule_host_headers" {
  type = list(string)
  default = []
}

variable "enable_service_connect" {
  type    = bool
  default = false
}
variable "service_connect_namespace" {
  type    = string
  default = "default"
}
variable "service_connect_discovery_name" {
  type    = string
  default = ""
}
variable "service_connect_port_name" {
  type    = string
  default = ""
}
variable "service_connect_ingress_port_override" {
  type    = number
  default = 0
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "health_check_grace_period_seconds" {
  type    = number
  default = 60
}

