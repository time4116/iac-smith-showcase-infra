# kinesis-firehose-s3-pipeline (non-prod)

Terragrunt stack for the [`kinesis-firehose-s3-pipeline` module](../../../modules/kinesis-firehose-s3-pipeline/README.md) in `non-prod`.

* Remote state: configured by [`../root.hcl`](../root.hcl) (S3 backend with DynamoDB locking, one state file per stack)
* Region: `us-west-2`
* Depends on the `vpc-foundation` stack (consumes `spec_summary`, `vpc_id`, `vpc_cidr_block`, `private_subnets`, `public_subnets`)

Pull requests are validated by `terraform-pr-check.yml`; after merge, `terraform-apply.yml` plans and applies this stack behind a manual environment approval gate.
