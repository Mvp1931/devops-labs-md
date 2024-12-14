variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "admin_password" {
  description = "Administrator password for the VM"
  type        = string
  sensitive   = true  # Marks the password as sensitive to prevent accidental exposure
}

