# Project: Terraform-provisioned GKE cluster

Terraform that provisions a VPC, GKE cluster and Cloud SQL (PostgreSQL) from a clean GCP
project, and deploys a small Go service onto the cluster.
Full spec and acceptance criteria: @docs/PROJECT_SPEC.md

## Working rules
- Build in the order listed in the spec, one module/resource group at a time.
- Never run `terraform apply` or `terraform destroy` yourself. Run `fmt`, `validate` and `plan`,
  then walk through the plan output. The human runs apply/destroy.

## Cost guardrails (non-negotiable)
- Before the first apply, confirm a GCP billing budget and alert exist for this project.
- Everything in `infra/` comes down with `terraform destroy` at the end of each session.
- Before adding anything billable while idle (Cloud NAT, load balancers, static IPs, node pools,
  Cloud SQL tiers), state what it costs to leave running and confirm first.
- Prefer the smallest machine types and a single zone. Note the production alternative.

## Stack
- Terraform (HCL), Google provider, GCP
- GKE cluster, custom VPC with subnets and secondary ranges, firewall rules
- Cloud SQL (PostgreSQL) with private connectivity
- One small service (Go) deployed on the cluster via Kubernetes manifests or Helm

## Repo layout
- `bootstrap/` Terraform root applied once and never destroyed: APIs, billing budget, Terraform
  service account, state bucket (see DECISIONS.md #1)
- `infra/` Terraform root that is destroyed and rebuilt; `infra/modules/` for vpc, gke, cloudsql
- `app/` the sample service and its Dockerfile
- `docs/` spec, architecture diagram, decision log
- `README.md` architecture diagram plus the "why" for each major resource

## Conventions
- Run `terraform fmt` and `terraform validate` before presenting any change.
- Variables for everything environment-specific; no hardcoded project IDs or secrets in git.
- Remote state in a GCS bucket once the basics work (bonus item in the spec).
- Keep a running `docs/DECISIONS.md`: one entry per non-obvious choice, with the alternatives rejected.
- Commit in small steps with clear messages.

## Definition of done (summary, see spec for details)
- Clean `destroy` then `apply` rebuilds everything with zero manual steps, timed, target under 20 minutes.
- README with architecture diagram and a reason for each resource choice.
