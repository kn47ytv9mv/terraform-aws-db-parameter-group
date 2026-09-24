variable "name" {
  default     = null
  description = "Name of the parameter group. Must begin with a letter — AWS rejects a name starting with a digit or a hyphen. If null, a unique name is generated."

  validation {
    condition     = var.name == null || can(regex("^[a-zA-Z]", var.name))
    error_message = "A parameter group's name must begin with a letter."
  }
}

variable "description" {
  default     = null
  description = "Description of the parameter group. If null, AWS's own default applies."
}

variable "family" {
  default     = null
  description = "The database family these parameters apply to (e.g. 'postgres17', 'mysql8.0', 'aurora-postgresql16'). Must match the engine and major version of every instance using this group — AWS rejects a mismatch outright."
}

variable "parameters" {
  default     = []
  description = "Parameters to set, each with a name and value. apply_method is 'immediate' (the default, applied as soon as it is set) or 'pending-reboot' (applied at the next reboot) — a static parameter only accepts 'pending-reboot', and AWS rejects 'immediate' on one."
  type = list(object({
    name         = string
    value        = string
    apply_method = optional(string)
  }))

  validation {
    condition     = alltrue([for p in var.parameters : p.apply_method == null || contains(["immediate", "pending-reboot"], p.apply_method)])
    error_message = "A parameter's apply_method must be either 'immediate' or 'pending-reboot'."
  }
}

variable "skip_destroy" {
  default     = false
  description = "Whether to leave the parameter group in place on destroy rather than deleting it. Useful when a group outlives the configuration that created it."
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the parameter group."
}
