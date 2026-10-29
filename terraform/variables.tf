variable "subscription_id" {
  description = "Azure subscription selected by the operator. No default is provided."
  type        = string
  sensitive   = true
  nullable    = false
}

variable "enable_deployment" {
  description = "Explicitly enables creation of all Azure resources. Keep false for local validation; requires separate cost/security approval."
  type        = bool
  default     = false
}

variable "deployment_acknowledgement" {
  description = "Must equal AZURE_COST_REVIEWED_AND_APPROVED to allow resource creation. This is an acknowledgement, not a credential."
  type        = string
  default     = ""
  validation {
    condition     = !var.enable_deployment || var.deployment_acknowledgement == "AZURE_COST_REVIEWED_AND_APPROVED"
    error_message = "Resource creation requires explicit cost review acknowledgement."
  }
}

variable "location" {
  description = "Azure region for the deployment."
  type        = string
  default     = "canadacentral"
}

variable "environment" {
  description = "Short environment label used in resource names and tags."
  type        = string
  default     = "lab"
  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.environment))
    error_message = "environment must be 2-8 lowercase letters or digits."
  }
}

variable "address_space" {
  description = "Private VNet address space reserved for this environment."
  type        = string
  default     = "10.84.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.address_space)) && split("/", var.address_space)[1] == "16" && can(regex("^(10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.|192\\.168\\.)", var.address_space))
    error_message = "address_space must be an RFC1918 /16 because this design allocates /24 subnets from it. Check for overlap before connecting networks."
  }
}

variable "enable_linux_vm" {
  description = "Creates a billable VM only when explicitly enabled after cost review. Defaults off."
  type        = bool
  default     = false
}

variable "vm_size" {
  description = "VM size selected after regional price and quota review."
  type        = string
  default     = "Standard_B2als_v2"
}

variable "ssh_public_key" {
  description = "SSH public key used only for the optional Linux VM. Private keys must never be supplied."
  type        = string
  default     = ""
  sensitive   = true
  validation {
    condition     = !var.enable_linux_vm || can(regex("^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp)", var.ssh_public_key))
    error_message = "When the optional VM is enabled, provide a supported SSH public key, never a private key."
  }
}

variable "linux_image_version" {
  description = "Explicit Ubuntu image version selected after publisher/region verification; no floating latest image is used."
  type        = string
  default     = ""
  validation {
    condition     = !var.enable_linux_vm || (var.linux_image_version != "" && lower(var.linux_image_version) != "latest")
    error_message = "Select and pin an explicit image version before enabling the optional VM."
  }
}

variable "enable_log_analytics" {
  description = "Creates a billable Log Analytics workspace. Defaults off."
  type        = bool
  default     = false
}
