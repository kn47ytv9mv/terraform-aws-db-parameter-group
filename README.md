# terraform-aws-db-parameter-group

Terraform module for an RDS DB parameter group — engine configuration
applied to the database instances that reference it.

## Cost

DB parameter groups carry no charge. This module has no cost impact of
its own.

## Design

Split from
[`terraform-aws-db-instance`](https://github.com/kn47ytv9mv/terraform-aws-db-instance)
because one parameter group is routinely shared by every instance
running the same engine and configuration — a 1:many relationship, and
an outside consumer references the group by name.

`family` must match the engine and major version of every instance
using this group (`postgres17`, `mysql8.0`, `aurora-postgresql16`, and
so on). AWS rejects a mismatch outright, and the failure surfaces when
the instance is created rather than when the group is.

A parameter's `apply_method` is `'immediate'` or `'pending-reboot'`.
AWS classifies each engine parameter as dynamic or static: a static
parameter only accepts `'pending-reboot'` and is rejected with
`'immediate'`. Which parameters are static is engine-specific and
documented by AWS per engine, not discoverable from this module.

A generated name is prefixed (`pg-`) because AWS requires a parameter
group name to begin with a letter, and a bare UUID may begin with a
digit. An explicitly supplied `name` is validated against the same
rule, so the failure arrives at plan time with a clear message rather
than from the provider mid-apply.

## Usage

```hcl
module "parameter_group" {
  source = "kn47ytv9mv/db-parameter-group/aws"

  family = "postgres17"

  parameters = [
    { name = "log_connections", value = "1" },
  ]
}
```

Or directly from this repository, with a static parameter that must
wait for a reboot:

```hcl
module "parameter_group" {
  source = "github.com/kn47ytv9mv/terraform-aws-db-parameter-group"

  name   = "production-postgres"
  family = "postgres17"

  parameters = [
    { name = "log_connections", value = "1" },
    { name = "shared_buffers", value = "16384", apply_method = "pending-reboot" },
  ]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | Name of the parameter group. Must begin with a letter — AWS rejects a name starting with a digit or a hyphen. If null, a unique name is generated. | `null` | no |
| description | Description of the parameter group. If null, AWS's own default applies. | `null` | no |
| family | The database family these parameters apply to (e.g. `'postgres17'`, `'mysql8.0'`, `'aurora-postgresql16'`). Must match the engine and major version of every instance using this group — AWS rejects a mismatch outright. | `null` | no |
| parameters | Parameters to set, each with a `name` and `value`. `apply_method` is `'immediate'` (the default, applied as soon as it is set) or `'pending-reboot'` (applied at the next reboot) — a static parameter only accepts `'pending-reboot'`, and AWS rejects `'immediate'` on one. | `[]` | no |
| skip_destroy | Whether to leave the parameter group in place on destroy rather than deleting it. Useful when a group outlives the configuration that created it. | `false` | no |
| tags | A map of tags to assign to the parameter group. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID (name) of the parameter group. |
| arn | The ARN of the parameter group. |
| name | The name of the parameter group. Feed this into `terraform-aws-db-instance`'s `parameter_group_name`. |

## License

MIT — see [LICENSE.md](LICENSE.md).
