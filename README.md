# azure-infra-terraform

[![Terraform checks](https://github.com/hamza2829/azure-infra-terraform/actions/workflows/terraform.yml/badge.svg)](https://github.com/hamza2829/azure-infra-terraform/actions/workflows/terraform.yml)

## What it is

A small Terraform example for Azure using the `azurerm` provider and five local
modules: resource group, network, storage, monitoring, and Linux VM.
**This project has not been deployed to a real Azure account.** Resource names,
network settings, and telemetry routes are proposed configuration, not proof of
working infrastructure or compliance.

| Module | Proposed resources |
| --- | --- |
| `resource-group` | One resource group in West Europe |
| `network` | VNet, workload/management/endpoint subnets, NSG and associations, egress NAT gateway/public IP |
| `storage` | Private StorageV2 account, Blob private endpoint/DNS, Blob diagnostics |
| `monitoring` | Log Analytics workspace with 90-day retention |
| `compute` | Private Ubuntu Linux VM, managed identity, Monitor Agent, collection rule, platform metrics |

The VM has no public IP. Only a designated private management host may reach SSH;
workload-to-Blob HTTPS is allowed. Other inbound traffic is denied. Outbound rules
allow HTTPS, Azure DNS, and required Azure platform-agent ports. NAT supplies
explicit outbound connectivity. No management host, VPN, or Bastion is included.
No application, container, or Docker installation is required.

Names and tags (`env`, `owner`, `cost-center`, plus `project` and `managed-by`) come
from root locals. See [naming and tagging](docs/naming-and-tagging.md) and the
[security checklist](docs/security.md) for rules, log destinations, and limitations.
Root outputs expose resource/subnet IDs, storage name, VM private IP, and identity;
they do not expose account keys or private SSH keys.

## What is checked in CI

[The workflow](.github/workflows/terraform.yml) runs on **every push**, pull request,
and manual dispatch, in three independent jobs so a failure does not hide the
other checks:

1. `terraform fmt -check -recursive`
2. `terraform init -backend=false -input=false -lockfile=readonly`
3. `terraform validate -no-color`
4. `tflint --init`, then TFLint recursively on root and child modules using the Azure ruleset
5. Checkov scanning Terraform and the GitHub Actions workflow

The workflow requires no Azure login, subscription, secrets, Docker, plan, or apply.
Terraform is pinned to 1.17.1, AzureRM to 4.38.1, TFLint to 0.65.0, the Azure
ruleset to 0.33.0, and Checkov to 3.4.0. The provider lock file includes Linux and
Windows checksums. Action dependencies use fixed commit hashes. The badge shows
GitHub's actual latest workflow status; it is not a deployment badge.

### Accepted Checkov findings

These are narrowly scoped inline skips on the affected resources. There is no
blanket skip, soft-fail, or `continue-on-error`. Other findings fail CI.

| ID | Affected resource | Reason and limitation |
| --- | --- | --- |
| `CKV_AZURE_50` | Linux VM | Extensions are intentionally enabled for Azure Monitor Agent and guest logs. Restrict extension write permissions through Azure RBAC in a real account; that governance is not implemented here. |
| `CKV_AZURE_36` | Storage account | Trusted Microsoft Services bypass is disabled because no service in this design needs to read the account through that bypass. Access is through private Blob networking; enabling a broad bypass would weaken the intended boundary. |
| `CKV_AZURE_33` | Storage account | Queue service is unused and has no private endpoint. Blob diagnostics are configured instead. Revisit Queue logging before introducing queues; this is not account-wide service logging coverage. |
| `CKV2_AZURE_1` | Storage account | No critical data or resources are deployed. Platform-managed keys plus infrastructure encryption are the example baseline. Customer-managed keys/Key Vault and key rotation are not implemented; evaluate them for real data requirements. |

`--skip-download` avoids downloading optional Prisma Cloud policy metadata; the
pinned Checkov package still runs its built-in checks locally. It does not skip
security checks. External module downloads are disabled because all modules are local.

## What is not done (no real Azure deployment)

- **No real Azure deployment, `terraform plan`, or `terraform apply` has been run.**
  CI verifies static configuration only; it cannot prove runtime connectivity,
  Azure API acceptance, image/SKU availability, quotas, cost, or actual log delivery.
- No Azure credentials, state files, private keys, or real subscription IDs are checked in.
- No remote state backend, management access path, storage data RBAC, backup/restore
  policy, subscription Activity Logs, VNet flow logs, alerts, or Defender rollout.
- No compliance certification, availability/SLA claim, or production readiness claim.
  Platform-managed keys are used; regulatory requirements need separate review.
- The example storage suffix is not reserved globally. The VM image is `latest`;
  a real rollout should pin/test an image. Platform encryption support, package
  repositories over HTTPS, outbound agent dependencies, and diagnostic categories
  would need live verification. VM, NAT, storage, and log ingestion would incur costs.

## How to run the checks locally

Install Terraform **1.17.1**, TFLint **0.65.0**, and Python **3.11**, then clone this
repository and run the following from its root. No Azure credentials are needed:

```sh
python -m venv .venv
# Linux/macOS:
. .venv/bin/activate
# PowerShell instead: .venv\Scripts\Activate.ps1
python -m pip install -r requirements-checks.txt

terraform fmt -check -recursive
terraform init -backend=false -input=false -lockfile=readonly
terraform validate -no-color
tflint --init
tflint --recursive --config="$(pwd)/.tflint.hcl"
checkov --directory . --framework terraform github_actions --download-external-modules false --skip-download --compact
```

For PowerShell, the TFLint command is:

```powershell
tflint --recursive --config="$PWD/.tflint.hcl"
```

Registry/GitHub/PyPI downloads require Internet access. `terraform validate` does
not require `ssh_public_key` or a tfvars file. `terraform.tfvars.example` documents
inputs only; its SSH key placeholder must be replaced with a public key for any
future planning exercise. Keep local `terraform.tfvars`, plans, and state out of Git.
There are deliberately no deployment instructions or Azure authentication steps.
The storage account has `lifecycle.prevent_destroy = true` to guard against
accidental deletion in a future deployment. A deliberate deletion would require
reviewing/removing that guard in configuration first.
