resource "aws_ecs_service" "vite_service" {
  name            = "${var.project_name}_${var.environment}_service"
  cluster         = aws_ecs_cluster.vite_cluster.id
  task_definition = aws_ecs_task_definition.vite_task.arn
  desired_count   = 2

  launch_type           = "FARGATE"
  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    subnets         = aws_subnet.vite_subnet_private.*.id // Deploy tasks within private subnets
    assign_public_ip = false // Public IP assignment not applicable in private subnets
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.vite_tg.arn
    container_name   = "do_react_vite"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.vite_listener
  ]

  tags = {
    Name        = "${var.project_name}_${var.environment}_service"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
