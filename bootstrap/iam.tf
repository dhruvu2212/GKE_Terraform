locals {
  terraform_sa_roles = [
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/container.admin",
    "roles/cloudsql.admin",
    "roles/servicenetworking.networksAdmin",
    "roles/artifactregistry.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    # Needed to grant roles to workload SAs; see DECISIONS.md #3 for the escalation risk.
    "roles/resourcemanager.projectIamAdmin",
  ]
}

resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform (infra root)"

  depends_on = [google_project_service.this["iam.googleapis.com"]]
}

resource "google_project_iam_member" "terraform" {
  for_each = toset(local.terraform_sa_roles)

  project = var.project_id
  role    = each.value
  member  = google_service_account.terraform.member
}

resource "google_service_account_iam_member" "admin_token_creator" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "user:${var.admin_email}"
}
