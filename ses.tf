// Create an SES domain identity
resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

// Verify the identity
resource "aws_ses_domain_identity_verification" "ses" {
  // Wait for the Route53 record to complete
  depends_on = [
    aws_route53_record.ses_verification
  ]
  domain = aws_ses_domain_identity.ses.id
}

// Create DKIM records for the SES domain
resource "aws_ses_domain_dkim" "ses" {
  domain = aws_ses_domain_identity.ses.domain
}

// Determine which MAIL FROM domain to use
locals {
  mail_from_configuration = var.mail_from_configuration != null ? var.mail_from_configuration : {
    domain         = "mail.${aws_ses_domain_identity.ses.domain}"
    hosted_zone_id = var.hosted_zone_id
  }
}

// Set the MAIL FROM domain
resource "aws_ses_domain_mail_from" "ses" {
  domain                 = aws_ses_domain_identity.ses.domain
  mail_from_domain       = local.mail_from_configuration.domain
  behavior_on_mx_failure = "RejectMessage"
}
