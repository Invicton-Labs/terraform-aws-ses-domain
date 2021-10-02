// Add a TXT record for verifying the SES domain identity
resource "aws_route53_record" "ses_verification" {
  zone_id         = var.hosted_zone_id
  name            = "_amazonses.${var.domain}"
  type            = "TXT"
  ttl             = "600"
  records         = [aws_ses_domain_identity.ses.verification_token]
  allow_overwrite = false
}

// Add the DKIM records to the domain
resource "aws_route53_record" "ses_dkim" {
  count           = 3
  zone_id         = var.hosted_zone_id
  name            = "${element(aws_ses_domain_dkim.ses.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type            = "CNAME"
  ttl             = "600"
  records         = ["${element(aws_ses_domain_dkim.ses.dkim_tokens, count.index)}.dkim.amazonses.com"]
  allow_overwrite = false
}

// Add a MX record for the custom MAIL FROM domain
resource "aws_route53_record" "ses_domain_mail_from_mx" {
  zone_id = local.mail_from_configuration.hosted_zone_id
  name    = aws_ses_domain_mail_from.ses.mail_from_domain
  type    = "MX"
  ttl     = "600"
  // Predetermined by SES (only the region name changes)
  records         = ["10 feedback-smtp.${data.aws_region.current.name}.amazonses.com"]
  allow_overwrite = false
}

// And a SPF record for the custom MAIL FROM domain
resource "aws_route53_record" "ses_domain_mail_from_spf" {
  zone_id         = local.mail_from_configuration.hosted_zone_id
  name            = aws_ses_domain_mail_from.ses.mail_from_domain
  type            = "TXT"
  ttl             = "600"
  records         = ["v=spf1 include:amazonses.com -all"]
  allow_overwrite = false
}

// Prepare the DMARC record value string from the configuration variable
locals {
  dmarc_record_value = var.dmarc_configuration != null ? "v=DMARC1; rf=afrf; p=${var.dmarc_configuration.policy}; sp=${var.dmarc_configuration.subdomain_policy}; pct=${var.dmarc_configuration.percentage}; rua=mailto:${var.dmarc_configuration.aggregate_report_address}; ruf=mailto:${var.dmarc_configuration.forensic_report_address}; fo=${join(":", var.dmarc_configuration.failure_reporting_options)}; adkim=${var.dmarc_configuration.dkim_alignment_mode}; aspf=r; ri=${var.dmarc_configuration.report_interval_seconds}" : null
}

// Add a TXT record for DMARC
resource "aws_route53_record" "dmarc" {
  count   = var.dmarc_configuration != null ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = "300"
  records = [
    local.dmarc_record_value
  ]
}
