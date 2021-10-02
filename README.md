## SES Domain

This module creates and fully validates an SES domain identity, including DKIM, SPF, custom MAIL FROM domain, and DMARC.

# Usage
```
locals {
    domain_name = "mydomain.com"
}

module "ses_domain" {
  source         = "Invicton-Labs/ses-domain/aws"
  domain         = local.domain_name
  hosted_zone_id = aws_route53_zone.mydomain.id
  mail_from_configuration = {
    domain         = "mailer.${local.domain_name}"
    hosted_zone_id = aws_route53_zone.mydomain.id
  }
  dmarc_configuration = {
    // Sample email addresses of where you might want reports sent.
    // We prefer to use a single address with "+" followed by domain details, so a single
    // email address can receive the reports, but can filter them based on the "DeliveredTo" header.
    aggregate_report_address  = "myname+dmarc-aggregate-${local.domain_name}@myemaildomain.net"
    forensic_report_address   = "myname+dmarc-forensic-${local.domain_name}@myemaildomain.net"

    // Send 100% of messages that fail DMARC validation to spam
    percentage                = 100

    // Send 1 report per day
    report_interval_seconds   = 86400

    // Generate a DMARC failure report if any underlying authentication mechanism (SPF or DKIM) produced something other than an aligned "pass" result.
    failure_reporting_options = ["1"]

    // Reject any messages that don't meet our DMARC policy.
    policy                    = "reject"
    subdomain_policy          = "reject"

    // Use strict DKIM alignment, so the DKIM selector must be on the same domain as the HEADER FROM domain
    dkim_alignment_mode       = "s"
  }
}
```
