variable "project" {
  description = "Short project code used in resource names (2-8 lowercase letters/digits, starting with a letter)."
  type        = string
  default     = "azdemo"
  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,7}$", var.project))
    error_message = "Use 2-8 lowercase letters/digits, starting with a letter."
  }
}

variable "env" {
  description = "Environment tag and name component; prod is a label, not a readiness claim."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "test", "prod"], var.env)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "owner" {
  description = "Accountable team; use a team alias rather than personal information."
  type        = string
  default     = "example-team"
  validation {
    condition     = length(trimspace(var.owner)) > 0 && length(var.owner) <= 64
    error_message = "Provide a nonempty owner of at most 64 characters."
  }
}

variable "cost_center" {
  description = "Billing allocation code, mapped to the cost-center tag."
  type        = string
  default     = "sandbox"
  validation {
    condition     = length(trimspace(var.cost_center)) > 0 && length(var.cost_center) <= 64
    error_message = "Provide a nonempty cost center of at most 64 characters."
  }
}

variable "instance" {
  description = "Three-digit instance number."
  type        = string
  default     = "001"
  validation {
    condition     = can(regex("^[0-9]{3}$", var.instance))
    error_message = "Use exactly three digits."
  }
}

variable "unique_suffix" {
  description = "Six lowercase letters/digits for the globally unique storage account name; demo01 is only an example."
  type        = string
  default     = "demo01"
  validation {
    condition     = can(regex("^[a-z0-9]{6}$", var.unique_suffix))
    error_message = "Use exactly six lowercase letters/digits."
  }
}

variable "ssh_public_key" {
  description = "An operator-supplied RSA public key; never supply a private key. Not needed for static CI checks."
  type        = string
  validation {
    condition     = can(regex("^ssh-rsa [A-Za-z0-9+/=]+( .*)?$", trimspace(var.ssh_public_key)))
    error_message = "Supply an OpenSSH RSA public key."
  }
}

variable "management_ssh_cidr" {
  description = "Single SSH source in the fixed 10.42.2.0/24 management subnet; no access host or VPN is provisioned."
  type        = string
  default     = "10.42.2.4/32"
  validation {
    condition     = can(cidrnetmask(var.management_ssh_cidr)) && can(regex("^10\\.42\\.2\\.[0-9]{1,3}/32$", var.management_ssh_cidr))
    error_message = "Use one valid /32 address in 10.42.2.0/24."
  }
}
