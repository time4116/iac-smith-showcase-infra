output "spec_summary" {
  description = "Human-readable summary of the rendered infrastructure spec."
  value       = "Rendered deterministic IaC Smith structure for ${var.environment}"
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer for public access to nginx"
  value       = aws_lb.nginx_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.nginx_alb.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.nginx_cluster.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.nginx_service.name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.nginx_tg.arn
}
