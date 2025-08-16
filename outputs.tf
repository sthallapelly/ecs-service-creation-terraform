output "services" {
  value = {
    for k, m in module.service : k => {
      service_arn      = m.service_arn
      target_group_arn = m.target_group_arn
      listener_rule_arn = m.listener_rule_arn
    }
  }
}
