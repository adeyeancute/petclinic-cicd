data "aws_route53_zone" "main" {
  count        = local.use_custom_domain ? 1 : 0
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "app" {
  count   = local.use_custom_domain ? 1 : 0
  zone_id = data.aws_route53_zone.main[0].zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.app.domain_name
    zone_id                = aws_cloudfront_distribution.app.hosted_zone_id
    evaluate_target_health = false
  }
}
