output "service_name"      { value = aws_ecs_service.this.name }
output "service_arn"       { value = aws_ecs_service.this.arn }
output "target_group_arn"  { value = aws_lb_target_group.this.arn }
output "listener_rule_arn" { value = try(aws_lb_listener_rule.this[0].arn, "") }
