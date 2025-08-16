resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  encryption_configuration {
    encryption_type = var.encryption_type
  }
  tags = var.tags
}

resource "aws_ecr_repository_policy" "this" {
  count      = var.set_policy ? 1 : 0
  repository = aws_ecr_repository.this.name
  policy     = var.repository_policy_json
}
