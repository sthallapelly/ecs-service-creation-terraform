aws_region        = "us-east-1"
cluster_arn       = "arn:aws:ecs:us-east-1:1234567890:cluster/my-ecs-cluster"
vpc_id            = "vpc-0fb85e9c66523ab94"
subnet_ids        = ["subnet-1234567890", "subnet-0987654321"]
security_group_ids = ["sg-123409876"]

services_file     = "examples/services.json"

# Optional IAM role ARNs (leave empty to set per-service in services.json)
execution_role_arn = "arn:aws:iam::1234567890:role/ecsTaskExecutionRole"
task_role_arn      = "arn:aws:iam::1234567890:role/ecsTaskExecutionRole"

# Existing ALB listener for all services
listener_arn = "arn:aws:elasticloadbalancing:us-east-1:1234567890:listener/app/my-ecs-cluster/1234567890/0987654321"
