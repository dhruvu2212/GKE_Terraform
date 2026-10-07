data "google_project" "this" {
  project_id = var.project_id

  # Defers the read to apply time on a fresh project, after the API is enabled.
  depends_on = [google_project_service.this["cloudresourcemanager.googleapis.com"]]
}

resource "google_billing_budget" "monthly" {
  billing_account = var.billing_account_id
  display_name    = "${var.project_id}-monthly"

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]

    # Alert on gross usage so trial credits don't mask spend.
    credit_types_treatment = "EXCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      currency_code = var.budget_currency
      units         = tostring(var.budget_amount)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
  }
  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    threshold_percent = 1.0
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  depends_on = [google_project_service.this["billingbudgets.googleapis.com"]]
}
