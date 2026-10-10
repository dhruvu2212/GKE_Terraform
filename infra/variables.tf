variable "project_id" {
  description = "GCP project ID that hosts everything."
  type        = string
}

variable "region" {
  description = "Default region for regional resources."
  type        = string
  default     = "asia-south1"
}

variable "zone" {
  description = "Default zone for zonal resources."
  type        = string
  default     = "asia-south1-a"
}

variable "terraform_sa_email" {
  description = "Service account this root runs as (bootstrap output terraform_service_account_email)."
  type        = string
}
