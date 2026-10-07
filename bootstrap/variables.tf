variable "project_id" {
  description = "GCP project ID that hosts everything."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "asia-south1"
}

variable "billing_account_id" {
  description = "Billing account the budget is attached to (XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget, in the billing account's currency."
  type        = number
  default     = 2000 # INR
}

variable "budget_currency" {
  description = "Must match the billing account's currency."
  type        = string
  default     = "INR"
}

variable "admin_email" {
  description = "User allowed to impersonate the Terraform service account."
  type        = string
}
