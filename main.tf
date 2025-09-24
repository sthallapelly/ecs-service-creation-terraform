locals {
  services = jsondecode(file(var.services_file))
}

module "ecr" {
  source   = "./modules/ecr"
  for_each = local.services

  name = each.value.ecr_name
  tags = merge({ Service = each.key }, try(each.value.tags, {}))
}

module "task" {
  source   = "./modules/task_definition"
  for_each = local.services

  family         = each.value.task_family
  container_name = each.value.container.name
  image          = lookup(each.value.container, "image", "${module.ecr[each.key].repository_url}:latest")
  cpu            = lookup(each.value.container, "cpu", 0)
  memory         = lookup(each.value.container, "memory", 0)
  entry_point    = lookup(each.value.container, "entry_point", [])
  command        = lookup(each.value.container, "command", [])
  port_mappings  = lookup(each.value.container, "port_mappings", [])
  environment    = lookup(each.value, "environment", {})
  secrets        = lookup(each.value, "secrets", {})
  environment_files = lookup(each.value.container, "environment_files", [])
  log_driver     = lookup(each.value.container, "log_driver", "awslogs")
  log_options    = lookup(each.value.container, "log_options", {
    "awslogs-group"        = "/ecs/${each.value.task_family}",
    "awslogs-region"       = var.aws_region,
    "awslogs-stream-prefix" = "ecs"
  })

  execution_role_arn =  var.execution_role_arn
  task_role_arn      =  var.execution_role_arn


  # NEW for CloudWatch Agent & Volumes
  enable_cloudwatch_agent      = lookup(each.value, "enable_cloudwatch_agent", false)
  cloudwatch_agent_config      = lookup(each.value, "cloudwatch_agent_config", null)
  main_container_mount_points  = lookup(each.value, "main_container_mount_points", [])
  volumes                      = lookup(each.value, "volumes", [])

  tags = merge({ Service = each.key }, try(each.value.tags, {}))
}

module "service" {
  source   = "./modules/service"
  for_each = local.services

  service_name       = each.value.service_name
  cluster_arn        = var.cluster_arn
  task_definition_arn = module.task[each.key].task_definition_arn
  desired_count      = lookup(each.value, "desired_count", 1)

  container_name = each.value.container.name
  container_port = each.value.container.port_mappings[0].container_port

  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  assign_public_ip   = lookup(each.value, "assign_public_ip", false)

  tg_name            = "${each.value.service_name}-tg"
  tg_port            = lookup(each.value, "target_group_port", 80)
  health_check_path  = lookup(each.value, "health_check_path", "/actuator/health")
  listener_arn       = var.listener_arn
  create_listener_rule = var.listener_arn != "" ? true : false
  listener_rule_priority = lookup(each.value, "listener_rule_priority", 100)
  rule_path_patterns     = lookup(each.value, "rule_path_patterns", ["/*"])
  rule_host_headers      = lookup(each.value, "rule_host_headers", [])
  rule_http_header_name  = lookup(each.value, "rule_http_header_name", "")
  rule_http_header_values = lookup(each.value, "rule_http_header_values", [])

  enable_service_connect                = lookup(each.value, "enable_service_connect", false)
  service_connect_namespace             = lookup(each.value, "service_connect_namespace", "default")
  service_connect_discovery_name        = each.value.service_connect_discovery_name
  service_connect_port_name             = lookup(each.value, "service_connect_port_name", "")
  service_connect_ingress_port_override = lookup(each.value, "service_connect_ingress_port_override", 0)

  tags = merge({ Service = each.key }, try(each.value.tags, {}))
}
