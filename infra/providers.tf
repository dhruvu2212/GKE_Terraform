provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone

  impersonate_service_account = var.terraform_sa_email
}
