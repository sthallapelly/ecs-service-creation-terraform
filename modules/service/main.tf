resource "aws_lb_target_group" "this" {
  name        = var.tg_name
  port        = var.tg_port
  protocol    = var.tg_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "this" {
  count        = var.create_listener_rule ? 1 : 0
  listener_arn = var.listener_arn
  priority     = var.listener_rule_priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  dynamic "condition" {
    for_each = length(var.rule_host_headers) > 0 ? [1] : []
    content {
      host_header { values = var.rule_host_headers }
    }
  }

  dynamic "condition" {
    for_each = length(var.rule_path_patterns) > 0 ? [1] : []
    content {
      path_pattern { values = var.rule_path_patterns }
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = var.task_definition_arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  platform_version = var.platform_version
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  enable_ecs_managed_tags = true


  deployment_controller { type = var.deployment_controller_type }

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = var.assign_public_ip
  }

  dynamic "load_balancer" {
    for_each = var.create_load_balancer ? [1] : []
    content {
      target_group_arn = aws_lb_target_group.this.arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  dynamic "service_connect_configuration" {
    for_each = var.enable_service_connect ? [1] : []
    content {
      namespace              = var.service_connect_namespace
      enabled = var.enable_service_connect
      service {
        discovery_name         = var.service_connect_discovery_name
        port_name = var.service_connect_port_name
        client_alias {
          port      = var.container_port
          dns_name = var.service_connect_discovery_name
        }
      # log_configuration {
      #   log_driver = "awslogs"
      #   options = {
      #     awslogs-group         = var.service_connect_log_group
      #     awslogs-region        = var.service_connect_log_region
      #     awslogs-stream-prefix = var.service_connect_log_prefix
      #   }
      }
    }
  }

  tags = var.tags

  depends_on = [aws_lb_listener_rule.this]
}
