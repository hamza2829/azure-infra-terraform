# Security checklist

This checklist describes Terraform configuration only. Nothing here has been
deployed or verified against a live Azure subscription. It is not a compliance certification.

## NSG and connectivity

- [x] Associate the NSG with all three subnets; enable private endpoint network policies.
- [x] Allow inbound TCP 22 to `10.42.1.0/24` only from `management_ssh_cidr`
  (default `10.42.2.4/32`, constrained to a single host in the management subnet).
- [x] Allow inbound TCP 443 to the endpoint subnet `10.42.3.0/24` only from the workload subnet.
- [x] Deny all other inbound traffic explicitly, including the default VNet allow rule.
- [x] Allow outbound TCP 22 only from the designated management host to the workload
  subnet, so the shared NSG also permits the initiating side of private SSH.
- [x] Allow workload outbound TCP 443 to the Internet for package/agent/monitoring
  endpoints, and TCP 443 to the private endpoint subnet. Destination hostnames are
  not restricted by an NSG; this is a documented limitation.
- [x] Allow workload outbound TCP/UDP 53 to `AzurePlatformDNS`, plus TCP 80/32526 to
  `168.63.129.16/32` for the Azure VM agent. Platform traffic has Azure-specific
  NSG behavior; these rules do not imply all platform traffic is filterable.
- [x] Deny other outbound traffic. NSGs are stateful, so response traffic for an
  allowed connection does not require a reverse allow rule.
- [x] Disable implicit outbound access. A NAT gateway gives the workload subnet
  explicit egress; its public IP has no inbound port mapping. The VM NIC has no public IP.
- [ ] Supply an actual private management path (VPN, peering, or Bastion) before
  using SSH. The empty management subnet and an allow rule do not create one.

## Logs

- [x] Configure Blob `allLogs` (read/write/delete) and metrics to the central Log
  Analytics workspace, with 90-day workspace retention.
- [x] Configure Azure Monitor Linux Agent plus a data collection rule/association
  for auth/authpriv/daemon/syslog at Info and higher, and CPU/memory counters.
- [x] Send VM platform metrics to the same workspace. Boot diagnostics use
  Azure-managed storage, separate from the project storage account and workspace.
- [x] Disable Log Analytics shared-key/local authentication; use Entra authentication.
- [ ] Verify actual ingestion, agent installation, retention, access roles, and
  alert delivery in a future live environment. No telemetry exists for this project today.
- [ ] Add subscription Activity Logs, VNet flow logs, alert rules, and an incident
  response process. NSG rules do not themselves produce traffic logs in this project.

## Settings that support compliance controls

- [x] Storage: TLS 1.2 minimum, HTTPS only, no public endpoint or anonymous blobs,
  no shared keys/local users, default-deny firewall, private Blob endpoint/DNS,
  cross-tenant replication disabled, infrastructure encryption, GRS replication,
  versioning, change feed, and 30-day blob/container soft deletion.
- [x] VM: SSH keys only, managed identity with no storage data role, host encryption,
  Secure Boot, vTPM, platform patching and assessment, and managed boot diagnostics.
  Cloud-init selects HTTPS Ubuntu package mirrors to match the egress rules.
- [x] Apply `env`, `owner`, and `cost-center` through root locals on taggable resources.
- [x] CI has read-only repository permissions, commit-pinned Actions, pinned tools,
  a committed provider lock file, and no Azure credentials or apply command.
- [ ] Decide regulatory retention, residency, customer-managed encryption keys,
  backups/restore drills, Defender coverage, access reviews, and policy enforcement
  based on actual requirements. Encryption currently uses platform-managed keys.
- [ ] Narrow HTTPS egress with a firewall if required, make monitoring private if
  required, and pin/test a concrete VM image version (currently `latest`).

See the README for the exact Checkov findings accepted for this example. Accepted
findings remain security limitations, even when CI is green.
