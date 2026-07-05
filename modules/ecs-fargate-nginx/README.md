# ecs-fargate-nginx

Declares the following resources:

* `aws_cloudwatch_log_group.ecs_logs`
* `aws_iam_role.ecs_task_execution_role`
* `aws_iam_role_policy_attachment.ecs_task_execution_role_policy`
* `aws_ecs_cluster.nginx_cluster`
* `aws_security_group.alb_sg`
* `aws_security_group_rule.alb_ingress_http`
* `aws_security_group_rule.alb_egress_all`
* `aws_security_group.ecs_tasks_sg`
* `aws_security_group_rule.ecs_tasks_ingress_from_alb`
* `aws_security_group_rule.ecs_tasks_egress_all`
* `aws_lb.nginx_alb`
* `aws_lb_target_group.nginx_tg`
* `aws_lb_listener.nginx_listener`
* `aws_ecs_task_definition.nginx_task`
* `aws_ecs_service.nginx_service`

## Inputs

| Name | Type |
|---|---|
| `aws_region` | `string` |
| `environment` | `string` |
| `private_subnets` | `list(string)` |
| `public_subnets` | `list(string)` |
| `spec_summary` | `string` |
| `vpc_cidr_block` | `string` |
| `vpc_id` | `string` |

## Outputs

| Name | Description |
|---|---|
| `spec_summary` | Human-readable summary of the rendered infrastructure spec. |
| `alb_dns_name` | DNS name of the Application Load Balancer for public access to nginx |
| `alb_arn` | ARN of the Application Load Balancer |
| `ecs_cluster_name` | Name of the ECS cluster |
| `ecs_service_name` | Name of the ECS service |
| `target_group_arn` | ARN of the target group |
