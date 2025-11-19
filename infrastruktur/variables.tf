variable "db_name" {
  description = "Database name"
  type        = string
  default     = "grocerymate_db"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "grocery_user"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "placeholder_password"  # This won't be used in plan, actual password is already set in AWS
}
