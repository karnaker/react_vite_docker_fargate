resource "aws_ecs_cluster" "vite_cluster" {
  name = "do_react_vite_cluster"

  # Tags for identifying and organizing resources within AWS.
  tags = {
    Name        = "${var.project_name}_${var.environment}_ecs_cluster"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = "true"
  }
}
