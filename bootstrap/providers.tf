# Runs as the caller's ADC: the Terraform SA is created by this root.
provider "google" {
  project = var.project_id
  region  = var.region

  # Budgets API needs a quota project when called with user credentials.
  user_project_override = true
  billing_project       = var.project_id
}
