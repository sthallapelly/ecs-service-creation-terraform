

# ECS Services Automation with Terraform

This repo provides a **modular, production-grade Terraform framework** for automating ECS Fargate service creation.
It covers everything from **ECR repositories** to **task definitions** (with optional sidecar containers) and **ECS services** with Service Connect and ALB integration.

---

## Features

* **Modular design** (`ecr`, `task_definition`, `service`)
* **Dynamic JSON-driven config** (`services.json`)
* **Environment variables + secrets** injected dynamically
* **Service Connect** (namespace, discovery, client-server mode, logs)
* **ALB integration** (target group, listener rule, health checks)
* **ECS managed tags** enabled
* **Health check grace period** (default: 60s)
* **CloudWatch Agent sidecar** (optional, with log volumes)
* **Container-level memory hard/soft limits**
* **Dynamic volumes + mount points**

---

## Project Structure

```
terraform-ecs-modular/
├─ modules/
│  ├─ ecr/
│  ├─ task_definition/
│  └─ service/
├─ examples/
│  └─ services.json
├─ main.tf
├─ variables.tf
├─ outputs.tf
├─ providers.tf
└─ README.md
```

---

## How It Works

### 1. ECR Module

Creates an Amazon ECR repository for each service:

```hcl
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = "MUTABLE"
}
```

---

### 2. Task Definition Module

Supports:

* Dynamic env vars and secrets
* Memory hard & soft limits
* Optional CloudWatch Agent sidecar
* Dynamic volumes + mount points

```hcl
container_definitions = jsonencode(local.container_definitions_list)

dynamic "volume" {
  for_each = var.volumes
  content {
    name      = volume.value.name
    host_path = try(volume.value.host_path, null)
  }
}
```

---

### 3. Service Module

Creates ECS Service with:

* Target group + ALB listener rule
* Health check grace period (default: 60s)
* ECS managed tags
* Service Connect (with logs)

```hcl
resource "aws_ecs_service" "this" {
  name      = var.service_name
  cluster   = var.cluster_arn
  desired_count = var.desired_count

  enable_ecs_managed_tags = true
  health_check_grace_period_seconds = 60
}
```

---

## Example `services.json`

### refer ` /examples/service.json `




---

## Runtime Variables (`terraform.tfvars`)

```hcl
aws_region         = "us-east-1"
cluster_arn        = "arn:aws:ecs:us-east-1:123456789:cluster/my-cluster"
vpc_id             = "vpc-abc123"
subnet_ids         = ["subnet-123", "subnet-456"]
security_group_ids = ["sg-12345"]
listener_arn       = "arn:aws:elasticloadbalancing:us-east-1:123:listener/app/my-alb/xxx/yyy"
```

---

## Usage

```bash
terraform init
terraform plan
terraform apply
```

---

## Future Enhancements

* Automated ALB listener priority conflict resolution
---

With this setup, you can **spin up ECS services dynamically** using only JSON definitions, while keeping your infrastructure **modular, reusable, and production-ready**.

---

