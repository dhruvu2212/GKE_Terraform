# Spec: Terraform-provisioned GKE cluster + service deployment

## Goal
Stand up a secure, reproducible application environment on GCP entirely from code: a single
engineer, starting from an empty project, with no manual console steps.

## Definition of done
- Public GitHub repo with working `.tf` files that provision, from a clean GCP project:
  a VPC, a GKE cluster and a Cloud SQL instance.
- One service (real or simplified) deployed onto that cluster through the same IaC flow.
- README with an architecture diagram and a "why" for each major resource choice.

## Success metric
`terraform destroy` followed by `terraform apply` fully rebuilds the environment with zero manual
steps. Time it and document it. Target: under 20 minutes end to end.

## Build order
1. GCP project setup: APIs enabled, billing budget and alert, service account for Terraform.
2. Provider config, variables, and local state (remote state comes later as a bonus).
3. VPC module: custom network, subnet, secondary ranges for pods and services, firewall rules.
4. GKE module: cluster and node pool, with the reasoning for each setting (zonal vs regional,
   machine type, private nodes or not, workload identity).
5. Cloud SQL module: PostgreSQL instance with private connectivity, and how the cluster reaches it.
6. Deploy the service onto the cluster (Kubernetes manifests or Helm) and verify it works.
7. Destroy and rebuild, timed. Fix anything that needed a manual step.
8. README, architecture diagram, `docs/DECISIONS.md` cleanup.

## Mandatory
- VPC, subnets and firewall rules defined in Terraform
- GKE cluster provisioned by Terraform, not clicked in the console
- Cloud SQL instance provisioned and connected to the cluster
- One real or simplified service deployed on top, reachable and working
- README explains resource choices (machine types, networking decisions, managed SQL vs self-hosted)

## Bonus
- Remote state backend in a GCS bucket instead of local state
- Variables or workspaces for a dev vs prod split
- Basic monitoring (Cloud Monitoring or a Prometheus exporter) wired in through the same IaC flow

## README must answer
- Why a custom VPC, why these machine types, why managed SQL, what breaks if one piece is removed.
- What would change for production (regional cluster, private nodes, state locking, CI for plan/apply).
