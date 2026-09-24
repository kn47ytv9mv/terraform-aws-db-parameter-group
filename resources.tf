resource "random_uuid" "resource" {}

resource "aws_db_parameter_group" "resource" {
  name         = coalesce(var.name, "pg-${random_uuid.resource.id}")
  description  = var.description
  family       = var.family
  skip_destroy = var.skip_destroy

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  tags = var.tags
}

output "id" {
  description = "The ID (name) of the parameter group."
  value       = aws_db_parameter_group.resource.id
}

output "arn" {
  description = "The ARN of the parameter group."
  value       = aws_db_parameter_group.resource.arn
}

output "name" {
  description = "The name of the parameter group. Feed this into terraform-aws-db-instance's parameter_group_name."
  value       = aws_db_parameter_group.resource.name
}
