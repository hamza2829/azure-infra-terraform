# Naming and tagging

The root `locals.tf` is the single source for names, region, and tags. Every module
receives `local.tags`; resources that support Azure tags use that map. Subnets,
NSG rules, associations, and diagnostic settings do not support tags in this
provider, so they inherit ownership through their resource group and names.

## Names

General form: `<type>-<project>-<env>-weu-<instance>`.

| Component | Rule | Example |
| --- | --- | --- |
| type | Azure resource abbreviation | `rg`, `vnet`, `vm`, `log` |
| project | 2-8 lowercase alphanumeric characters, first a letter | `azdemo` |
| env | `dev`, `test`, or `prod` | `dev` |
| region | Fixed `westeurope`, abbreviated `weu` | `weu` |
| instance | Three digits | `001` |

Examples: `rg-azdemo-dev-weu-001`, `vm-azdemo-dev-weu-001`.
Child resources add a purpose prefix to their parent's name, such as
`snet-workload-vnet-azdemo-dev-weu-001` and `osdisk-vm-azdemo-dev-weu-001`.
The private DNS zone uses Azure's required `privatelink.blob.core.windows.net` name.

Storage accounts cannot contain hyphens and must be globally unique. Their form
is `st<project><env><instance><unique_suffix>` (maximum 23 characters with the input
limits). `stazdemodev001demo01` is an example, not a reserved name. Choose a new
six-character suffix before any future deployment; CI cannot check availability.

## Tags

| Tag | Source | Purpose |
| --- | --- | --- |
| `env` | `var.env` | Environment classification |
| `owner` | Trimmed `var.owner` | Accountable team alias |
| `cost-center` | Trimmed `var.cost_center` | Billing allocation |
| `project` | `var.project` | Project grouping |
| `managed-by` | Literal `terraform` | Management method |

Environment, project, instance, and suffix have input validation. Owner and cost
center must be nonempty and at most 64 characters; these example values must be
replaced with real organizational codes in a future deployment. Do not put secrets
or personal information in tags. A `prod` label does not make this project production ready.
