mock_provider "aws" {}

run "invalid_apply_method_is_rejected" {
  command = plan

  variables {
    family = "postgres17"
    parameters = [
      { name = "log_connections", value = "1", apply_method = "whenever" },
    ]
  }

  expect_failures = [var.parameters]
}

run "digit_leading_name_is_rejected" {
  command = plan

  variables {
    name   = "0bad-name"
    family = "postgres17"
  }

  expect_failures = [var.name]
}

run "name_defaults_to_prefixed_random_uuid" {
  command = apply

  variables {
    family = "postgres17"
  }

  assert {
    condition     = aws_db_parameter_group.resource.name == "pg-${random_uuid.resource.id}"
    error_message = "Leaving name unset should fall back to a letter-prefixed random_uuid, since AWS rejects a parameter group name that does not begin with a letter."
  }
}

run "no_parameters_by_default" {
  command = plan

  variables {
    family = "postgres17"
  }

  assert {
    condition     = length(aws_db_parameter_group.resource.parameter) == 0
    error_message = "Leaving parameters unset should create a group with no parameter blocks."
  }
}

run "parameters_create_one_block_each" {
  command = plan

  variables {
    family = "postgres17"
    parameters = [
      { name = "log_connections", value = "1" },
      { name = "shared_buffers", value = "16384", apply_method = "pending-reboot" },
    ]
  }

  assert {
    condition     = length(aws_db_parameter_group.resource.parameter) == 2
    error_message = "Each entry in parameters should produce one parameter block."
  }
}

run "skip_destroy_defaults_false" {
  command = plan

  variables {
    family = "postgres17"
  }

  assert {
    condition     = aws_db_parameter_group.resource.skip_destroy == false
    error_message = "skip_destroy should default to false, so a destroy actually removes the group."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    family = "postgres17"
    parameters = [
      { name = "log_connections", value = "1" },
    ]
  }
}

run "readme_static_parameter_example" {
  command = plan

  variables {
    name   = "production-postgres"
    family = "postgres17"

    parameters = [
      { name = "log_connections", value = "1" },
      { name = "shared_buffers", value = "16384", apply_method = "pending-reboot" },
    ]
  }
}
