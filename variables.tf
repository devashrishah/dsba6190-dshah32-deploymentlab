variable "tag_class" {
  type    = string
  default = "dsba6190"
}

variable "tag_instructor" {
  type    = string
  default = "cford38"
}


variable "tag_semester" {
  type    = string
  default = "fall2025"
}

variable "location" {
  description = "Location of Resource Group"
  type        = string
  default     = "eastus"

  validation {
    condition     = contains(["eastus"], lower(var.location))
    error_message = "Unsupported Azure Region specified."
  }
}


// Azure-Specific App Variables

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "student_name" {
  description = "Application Name"
  type        = string
  default     = "dshah"
}

variable "class_name" {
  description = "Application Name"
  type        = string
  default     = "dsba6190"
}
variable "sql_admin_user" {
  description = "SQL Admin Username"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "SQL Admin Password"
  sensitive   = true
  default     = "MyStrongP@ssword123!"
}