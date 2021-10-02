output "identity" {
  depends_on = [
    aws_ses_domain_identity_verification.ses
  ]
  description = "The SES domain identity resource that was created. Will not return until the verification is complete."
  value       = aws_ses_domain_identity.ses
}

output "mail_from_domain" {
  description = "The MAIL FROM domain that is set for this SES domain identity."
  value       = local.mail_from_configuration.domain
}

output "dmarc_record_value" {
  description = "The string value of the DMARC record that was created (`null` if no DMARC record was created)."
  value       = local.dmarc_record_value
}
