"""Offline contracts: no credentials, providers, or cloud calls required."""
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / '.github/workflows/terraform-apply.yml'
MODULE = ROOT / 'modules/kinesis-firehose-s3-pipeline'


def resource(kind, name):
    text = (MODULE / 'main.tf').read_text().replace('\\"', '"')
    return text.split(f'resource "{kind}" "{name}" {{', 1)[1].split('\nresource ', 1)[0]


def job(name):
    return re.split(r'\n  [a-z-]+:', WORKFLOW.read_text().split(f'\n  {name}:', 1)[1])[0]


class InfrastructureContracts(unittest.TestCase):
    def scan(self, paths):
        text = WORKFLOW.read_text()
        script = text.split('          changed() {', 1)[1].split('\n\n  gate:', 1)[0]
        script = 'changed() {' + script
        script = '\n'.join(line[10:] if line.startswith('          ') else line for line in script.splitlines())
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / 'output'
            env = dict(os.environ, CHANGED='\n'.join(paths), WORKLOAD_STACKS='kinesis-firehose-s3-pipeline ecs-fargate-nginx', GITHUB_OUTPUT=str(output))
            subprocess.run(['bash', '-euo', 'pipefail', '-c', script], env=env, check=True)
            return dict(line.split('=', 1) for line in output.read_text().splitlines())

    def test_shared_root_selects_all_consumers(self):
        result = self.scan(['environments/non-prod/root.hcl'])
        self.assertEqual(result['foundation'], 'true')
        self.assertEqual(set(json.loads(result['stacks'])), {'kinesis-firehose-s3-pipeline', 'ecs-fargate-nginx'})
        self.assertEqual(result['bootstrap'], 'false')

    def test_pipeline_only_stays_scoped(self):
        result = self.scan(['modules/kinesis-firehose-s3-pipeline/main.tf'])
        self.assertEqual(json.loads(result['stacks']), ['kinesis-firehose-s3-pipeline'])
        self.assertEqual(result['foundation'], 'false')
        self.assertEqual(result['bootstrap'], 'false')

    def test_bootstrap_only_stays_scoped(self):
        result = self.scan(['bootstrap/backend/non-prod/main.tf'])
        self.assertEqual(result['bootstrap'], 'true')
        self.assertEqual(result['stacks'], '[]')

    def test_bucket_object_permissions_are_separate(self):
        policy = resource('aws_iam_role_policy', 'firehose_s3_write_policy')
        for action in ['GetBucketLocation', 'ListBucket', 'ListBucketMultipartUploads', 'AbortMultipartUpload', 'GetObject', 'PutObject']:
            self.assertIn('s3:' + action, policy)
        bucket, objects = re.split(r'Sid\s*=\s*"ObjectAccess"', policy)
        self.assertRegex(bucket, r'Sid\s*=\s*"BucketAccess"')
        self.assertEqual(set(re.findall(r's3:[A-Za-z]+', bucket)), {'s3:GetBucketLocation', 's3:ListBucket', 's3:ListBucketMultipartUploads'})
        self.assertEqual(set(re.findall(r's3:[A-Za-z]+', objects)), {'s3:AbortMultipartUpload', 's3:GetObject', 's3:PutObject'})
        self.assertRegex(bucket, r'Resource\s*=\s*aws_s3_bucket.delivery_bucket.arn')
        self.assertRegex(objects, r'Resource\s*=\s*"\$\{aws_s3_bucket.delivery_bucket.arn\}/\*"')

    def test_kinesis_permissions_are_valid_and_stream_scoped(self):
        policy = resource('aws_iam_role_policy', 'firehose_kinesis_read_policy')
        self.assertEqual(set(re.findall(r'kinesis:[A-Za-z]+', policy)), {'kinesis:DescribeStream', 'kinesis:GetShardIterator', 'kinesis:GetRecords'})
        self.assertIn('aws_kinesis_stream.data_stream.arn', policy)

    def test_logs_write_only_dedicated_stream(self):
        policy = resource('aws_iam_role_policy', 'firehose_cloudwatch_logs_policy')
        self.assertIn('aws_cloudwatch_log_stream.firehose_error_log_stream.arn', policy)
        self.assertNotIn('aws_cloudwatch_log_group.firehose_log_group.arn', policy)
        self.assertEqual(set(re.findall(r'logs:[A-Za-z]+', policy)), {'logs:PutLogEvents'})

    def test_delivery_waits_for_permissions_and_hardening(self):
        delivery = resource('aws_kinesis_firehose_delivery_stream', 's3_delivery_stream')
        self.assertIn('depends_on', delivery)
        dependencies = delivery.split('depends_on', 1)[1].split(']', 1)[0]
        for name in ['firehose_kinesis_read_policy', 'firehose_s3_write_policy', 'firehose_cloudwatch_logs_policy', 'delivery_bucket_versioning', 'delivery_bucket_encryption', 'delivery_bucket_public_access_block']:
            self.assertIn(name, dependencies)

    def test_standalone_pipeline_contract(self):
        stack = (ROOT / 'environments/non-prod/kinesis-firehose-s3-pipeline/terragrunt.hcl').read_text()
        self.assertNotIn('dependency', stack)
        variables = re.findall(r'variable "([^"]+)"', (MODULE / 'variables.tf').read_text())
        self.assertEqual(variables, ['environment'])
        self.assertNotIn('aws_region', stack)

    def test_bootstrap_failure_cannot_be_bypassed(self):
        workload = job('apply-workloads')
        self.assertIn('needs: [detect, gate, bootstrap, apply-foundation]', workload)
        self.assertIn("needs.bootstrap.result != 'failure'", workload)
        self.assertIn("needs.bootstrap.result != 'cancelled'", workload)
        for name in ['bootstrap', 'apply-foundation', 'apply-workloads']:
            self.assertIn("needs.gate.result == 'success'", job(name))

    def test_workload_rejects_failed_or_cancelled_bootstrap(self):
        match = re.search(r'if: \$\{\{ (.+) \}\}', job('apply-workloads'))
        assert match is not None
        expression = match.group(1)
        for gate in ['success', 'failure', 'cancelled', 'skipped']:
            for bootstrap in ['success', 'failure', 'cancelled', 'skipped']:
                for foundation in ['success', 'failure', 'cancelled', 'skipped']:
                    with self.subTest(gate=gate, bootstrap=bootstrap, foundation=foundation):
                        condition = expression.replace('always()', 'True').replace('&&', ' and ')
                        for key, value in [('needs.gate.result', gate), ('needs.bootstrap.result', bootstrap), ("needs['apply-foundation'].result", foundation), ('needs.detect.outputs.stacks', '["pipeline"]')]:
                            condition = condition.replace(key, repr(value))
                        actual = eval(condition, {'__builtins__': {}}, {})
                        expected = gate == 'success' and bootstrap in ['success', 'skipped'] and foundation in ['success', 'skipped']
                        self.assertEqual(actual, expected)

    def test_pinned_terragrunt_cli_is_supported(self):
        text = WORKFLOW.read_text()
        self.assertNotIn('--non-interactive', text)
        self.assertEqual(text.count('--terragrunt-non-interactive'), 4)

    def test_backend_generation_never_bootstraps(self):
        root = (ROOT / 'environments/non-prod/root.hcl').read_text()
        self.assertNotIn('remote_state {', root)
        self.assertIn('generate "backend"', root)
        self.assertIn('backend "s3"', root)
        self.assertIn('path_relative_to_include()', root)
        self.assertNotIn('releases/latest', WORKFLOW.read_text())
        self.assertEqual(WORKFLOW.read_text().count('TG_VERSION=v0.57.0'), 2)


if __name__ == '__main__':
    unittest.main()
