##################################################
# alb.tf (for now in main.tf) (continued)
# Application Load Balancer (ALB) for distributing traffic to the Fargate service
# Create a new HTTP listener which redirects to HTTPS.
# Create HTTPS listener. This is done after the certificate is created so that
# OpenTofu doesn't try to create the listener before we have a valid certificate.

resource "aws_alb_listener" "http_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.alb_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}
