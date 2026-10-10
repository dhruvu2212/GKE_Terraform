data "google_client_openid_userinfo" "caller" {}

output "caller_email" {
  description = "Identity Terraform is calling GCP as."
  value       = data.google_client_openid_userinfo.caller.email
}
