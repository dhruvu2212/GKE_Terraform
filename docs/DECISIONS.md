# Decision Log

One entry per non-obvious choice: what was chosen, why, and what was rejected.

---

## #1 Split Terraform into `bootstrap/` and `infra/` roots

**Date:** 2026-10-04

**Decision:** Two separate Terraform root modules, each with its own state:
- `bootstrap/` is applied once and never destroyed. It holds the API enablement, the billing budget and alert, the Terraform service account and (later) the GCS state bucket.
- `infra/` holds the VPC, GKE, Cloud SQL and the app. It is destroyed and rebuilt freely.

**Why:** The success metric is a timed `destroy` + `apply` of the whole environment. If everything lived in one root, `destroy` would also delete:
- the budget alert, the cost safety net, at the moment it matters most;
- the state bucket, in which case Terraform deletes the place where it records what exists;
- the service account that `infra/` runs as.

The two roots have different lifecycles, so they get different state. The pattern is commonly called a "bootstrap" or "foundation" layer.

**Alternatives rejected:**
- *Single root with `lifecycle { prevent_destroy = true }` on the long-lived resources:* `destroy` then errors out instead of skipping those resources, so you end up using `-target` gymnastics, which is fragile and goes against "zero manual steps".
- *Creating the budget, service account and bucket by hand in the console:* this isn't reproducible or reviewable, and it goes against the spirit of the project.
- *Terraform workspaces:* workspaces are meant for multiple copies of the *same* config (dev/prod), not for different lifecycles.

---

## #2 Terraform authenticates via service account impersonation, not key files

**Date:** 2026-10-04

**Decision:** I authenticate as myself with `gcloud auth application-default login`. The `infra/` provider then impersonates a dedicated Terraform service account, which `bootstrap/` creates, using short-lived (1h) tokens. I hold `roles/iam.serviceAccountTokenCreator` on that service account. No JSON key is ever created.

**Why:**
- Exported service-account keys are long-lived bearer credentials. They are the classic way GCP credentials leak (committed to git, left on laptops).
- With impersonation, a leaked token expires within an hour, and the audit logs show both *who* (me) and *as what* (the service account).
- The service account holds only the roles Terraform needs, so day-to-day changes don't run with my Owner rights.

**Alternatives rejected:**
- *Downloaded service-account JSON key in `GOOGLE_APPLICATION_CREDENTIALS`:* simplest, but a long-lived secret on disk. Many orgs block key creation by policy (`iam.disableServiceAccountKeyCreation`).
- *Running Terraform directly as my user (Owner):* works, but it has excess privilege, and there is no separation between "human" and "automation" identity.
- *Workload Identity Federation (keyless auth for CI such as GitLab or GitHub Actions):* this is the right answer once plan/apply runs in CI. That's out of scope for now and noted as a production improvement.

---

## #3 Curated roles for the Terraform service account, not `roles/editor`

**Date:** 2026-10-08

**Decision:** The `terraform` SA gets a specific list of admin roles that covers only the resource types `infra/` manages: network, firewall, GKE, Cloud SQL, service networking, Artifact Registry, SA admin/user, and project IAM admin. All grants use additive `google_project_iam_member`.

**Why:**
- Least privilege. The SA can't touch billing, delete the project, or manage services outside the list.
- A missing role surfaces as an explicit 403, which documents exactly what each resource needs.
- `roles/editor` can't grant IAM roles at all, so it would block the GKE node SA and Workload Identity setup anyway.

**Known risk:** `roles/resourcemanager.projectIamAdmin` can grant *any* role, including Owner to itself. That makes it a privilege-escalation path, and the curated list is only as strong as this role. It is accepted here because `infra/` must grant roles to the workload service accounts it creates.

**Production hardening (not done):**
- Add an IAM Condition that limits which roles the SA may grant (`modifiedGrantsByRole`).
- Or move workload SAs and their grants into `bootstrap/` and drop `projectIamAdmin` entirely.

**Alternatives rejected:**
- *`roles/editor`:* too broad, and it can't do IAM.
- *`roles/owner`:* defeats the purpose of a separate identity.
- *Authoritative `google_project_iam_binding`/`_policy`:* would strip Google-managed service agents and the human Owner from roles they share.
