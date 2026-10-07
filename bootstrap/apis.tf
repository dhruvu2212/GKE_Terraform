locals {
  # Includes APIs used by infra/, so rebuilds never wait on enablement.
  services = [
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com", # SA impersonation
    "billingbudgets.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com", # Cloud SQL private IP
    "artifactregistry.googleapis.com",
  ]
}

resource "google_project_service" "this" {
  for_each = toset(local.services)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
}
