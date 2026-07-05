# vpc-foundation (non-prod)

Terragrunt stack for the [`vpc-foundation` module](../../../modules/vpc-foundation/README.md) in `non-prod`.

* Remote state: configured by [`../root.hcl`](../root.hcl) (S3 backend with DynamoDB locking, one state file per stack)
* Region: `us-west-2`

Pull requests are validated by `terraform-pr-check.yml`; after merge, `terraform-apply.yml` plans and applies this stack behind a manual environment approval gate.
