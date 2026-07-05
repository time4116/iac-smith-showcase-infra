resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/nginx-${var.environment}"
  retention_in_days = 7
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role-${var.environment}"
  assume_role_policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Action\":\"sts:AssumeRole\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":\"ecs-tasks.amazonaws.com\"}}]}"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_cluster" "nginx_cluster" {
  name = "nginx-cluster-${var.environment}"
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "nginx-alb-sg-${var.environment}"
  description = "Security group for nginx ALB"
  vpc_id      = var.vpc_id
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type      = "ingress"
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP from anywhere"
}

resource "aws_security_group_rule" "alb_egress_all" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "nginx-ecs-tasks-sg-${var.environment}"
  description = "Security group for nginx ECS tasks"
  vpc_id      = var.vpc_id
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
}

resource "aws_security_group_rule" "ecs_tasks_ingress_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.ecs_tasks_sg.id
  description              = "Allow HTTP from ALB"
}

resource "aws_security_group_rule" "ecs_tasks_egress_all" {
  type      = "egress"
  from_port = 0
  to_port   = 0
  protocol  = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.ecs_tasks_sg.id
  description       = "Allow all outbound traffic"
}

resource "aws_lb" "nginx_alb" {
  name               = "nginx-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb_sg.id
  ]
  subnets                    = var.public_subnets
  enable_deletion_protection = false
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
}

resource "aws_lb_target_group" "nginx_tg" {
  name        = "nginx-tg-${var.environment}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

resource "aws_ecs_task_definition" "nginx_task" {
  family       = "nginx-${var.environment}"
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu                   = "256"
  memory                = "512"
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = "[{\"name\":\"nginx\",\"image\":\"nginx:latest\",\"portMappings\":[{\"containerPort\":80,\"hostPort\":80,\"protocol\":\"tcp\"}],\"logConfiguration\":{\"logDriver\":\"awslogs\",\"options\":{\"awslogs-group\":\"${aws_cloudwatch_log_group.ecs_logs.name}\",\"awslogs-region\":\"${var.aws_region}\",\"awslogs-stream-prefix\":\"ecs\"}},\"essential\":true}]"
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
}

resource "aws_ecs_service" "nginx_service" {
  name                               = "nginx-service-${var.environment}"
  cluster                            = aws_ecs_cluster.nginx_cluster.id
  task_definition                    = aws_ecs_task_definition.nginx_task.arn
  desired_count                      = 2
  launch_type                        = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  tags = {
    Environment = var.environment
    Service     = "nginx"
  }
  network_configuration {
    subnets = var.private_subnets
    security_groups = [
      aws_security_group.ecs_tasks_sg.id
    ]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
