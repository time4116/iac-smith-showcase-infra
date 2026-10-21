# kinesis-firehose-s3-pipeline (non-prod)

Terragrunt stack for the [`kinesis-firehose-s3-pipeline` module](../../../modules/kinesis-firehose-s3-pipeline/README.md) in `non-prod`.

* Remote state: configured by [`../root.hcl`](../root.hcl) (S3 backend with DynamoDB locking, one state file per stack)
* Region: `us-west-2`
* Standalone pipeline: no VPC/foundation state dependency; only `environment` is passed to the module
* Backend must already exist: root generates backend configuration only and never bootstraps during Terragrunt plan/init

Pull requests are validated by `terraform-pr-check.yml`; after merge, `terraform-apply.yml` plans and applies this stack behind a manual environment approval gate.
