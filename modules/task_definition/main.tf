locals {
  environment_list = [
    for k, v in var.environment : {
      name  = k
      value = v
    }
  ]

  secrets_list = [
    for k, v in var.secrets : {
      name      = k
      valueFrom = v
    }
  ]

  port_mappings = [
    for pm in var.port_mappings : {
      name          = lookup(pm, "name", "http-${pm.container_port}")
      containerPort = pm.container_port
      hostPort      = lookup(pm, "host_port", pm.container_port)
      protocol      = lookup(pm, "protocol", "tcp")
      appProtocol   = lookup(pm, "app_protocol", "http")
    }
  ]

  # Main application container
  main_container_def = merge({
    name         = var.container_name
    image        = var.image
    cpu          = var.cpu
    essential    = true
    entryPoint   = var.entry_point
    command      = var.command
    portMappings = [for p in local.port_mappings : {
      name          = p.name
      containerPort = p.containerPort
      hostPort      = p.hostPort
      protocol      = p.protocol
      appProtocol   = p.appProtocol
    }]
    environment      = local.environment_list
    environmentFiles = var.environment_files
    secrets          = local.secrets_list
    mountPoints = [
      for mp in var.main_container_mount_points : {
        sourceVolume  = mp.source_volume
        containerPath = mp.container_path
        readOnly      = mp.read_only
      }
    ]
    logConfiguration = {
      logDriver = var.log_driver
      options   = var.log_options
    }
  }, {})

  # Optional CloudWatch Agent sidecar container
  cloudwatch_container_def = var.enable_cloudwatch_agent ? [
    merge({
      name         = var.cloudwatch_agent_config.name
      image        = var.cloudwatch_agent_config.image
      cpu          = var.cloudwatch_agent_config.cpu
      essential    = true
      environment  = var.cloudwatch_agent_config.environment
      environmentFiles = var.cloudwatch_agent_config.environment_files
      mountPoints  = [
        for mp in var.cloudwatch_agent_config.mount_points : {
          sourceVolume  = mp.source_volume
          containerPath = mp.container_path
          readOnly      = mp.read_only
        }
      ]
      logConfiguration = {
        logDriver = var.cloudwatch_agent_config.log_configuration.log_driver
        options   = var.cloudwatch_agent_config.log_configuration.options
      }
    }, {})
  ] : []

  # Final list of containers
  container_definitions_list = concat([local.main_container_def], local.cloudwatch_container_def)
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = var.execution_role_arn != "" ? var.execution_role_arn : null
  task_role_arn            = var.task_role_arn != "" ? var.task_role_arn : null

  runtime_platform {
    operating_system_family = var.runtime_platform.os_family
    cpu_architecture        = var.runtime_platform.cpu_arch
  }

  container_definitions = jsonencode(local.container_definitions_list)

  dynamic "volume" {
    for_each = var.volumes
    content {
      name = volume.value.name

      host_path = try(volume.value.host_path, null)

      dynamic "docker_volume_configuration" {
        for_each = lookup(volume.value, "docker_volume_configuration", null) != null ? [1] : []
        content {
          scope         = volume.value.docker_volume_configuration.scope
          autoprovision = volume.value.docker_volume_configuration.autoprovision
          driver        = volume.value.docker_volume_configuration.driver
          driver_opts   = volume.value.docker_volume_configuration.driver_opts
          labels        = volume.value.docker_volume_configuration.labels
        }
      }
    }
  }

  tags = var.tags
}
