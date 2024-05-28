# Create certificate for HTTPS. Before turning on the HTTPS listener, validate
# your chosen domain with your DNS provider.
resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name        = "${var.project_name}-${var.environment}-alb-cert"
    Environment = var.environment
    Project     = var.project_name
    OpenTofu    = var.opentofu_enabled
  }
}

output "domain_validations" {
  value = aws_acm_certificate.alb_cert.domain_validation_options
}
