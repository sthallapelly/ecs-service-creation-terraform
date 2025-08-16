variable "family" { type = string }
variable "container_name" { type = string }
variable "image" { type = string }
variable "cpu" {
  type    = number
  default = 0
}
variable "memory" {
  type    = number
  default = 0
}
variable "entry_point" {
  type = list(string)
  default = []
}
variable "command" {
  type = list(string)
  default = []
}

variable "port_mappings" {
  type = list(object({
    name = optional(string)
    container_port = number
    host_port = optional(number)
    protocol = optional(string)
    app_protocol = optional(string)
  }))
  default = []
}

variable "environment" {
  type = map(string)
  default = {}
}
variable "secrets" {
  type = map(string)
  default = {}
}
# values must be ARN strings for valueFrom
variable "environment_files" {
  type = list(object({
    value = string
    type  = string
  }))
  default = []
}

variable "log_driver" {
  type    = string
  default = "awslogs"
}
variable "log_options" {
  type = map(string)
  default = {}
}

variable "network_mode" {
  type    = string
  default = "awsvpc"
}
variable "requires_compatibilities" {
  type = list(string)
  default = ["FARGATE"]
}
variable "task_cpu" {
  type    = string
  default = "1024"
}
variable "task_memory" {
  type    = string
  default = "2048"
}

variable "execution_role_arn" {
  type    = string
  default = ""
}
variable "task_role_arn" {
  type    = string
  default = ""
}

variable "runtime_platform" {
  type = object({
    os_family = string
    cpu_arch  = string
  })
  default = {
    os_family = "LINUX"
    cpu_arch  = "X86_64"
  }
}

variable "tags" {
  type = map(string)

  default = {}
}

variable "enable_cloudwatch_agent" {
  type    = bool
  default = false
  description = "Whether to add CloudWatch Agent sidecar container"
}

variable "main_container_mount_points" {
  type = list(object({
    source_volume  = string
    container_path = string
    read_only      = bool
  }))
  default = []
}

variable "volumes" {
  type = list(object({
    name = string
    host_path = optional(string)
    docker_volume_configuration = optional(object({
      scope         = string
      autoprovision = bool
      driver        = string
      driver_opts   = map(string)
      labels        = map(string)
    }))
  }))
  default = []
}

variable "cloudwatch_agent_config" {
  type = object({
    name            = string
    image           = string
    cpu             = number
    environment     = list(object({ name = string, value = string }))
    environment_files = list(object({ value = string, type = string }))
    mount_points    = list(object({
      source_volume  = string
      container_path = string
      read_only      = bool
    }))
    log_configuration = object({
      log_driver = string
      options    = map(string)
    })
  })
  default = null
}

