variable "domain" {
  description = "The domain to set up for sending and receiving."
  type        = string

  validation {
    condition     = length(regexall("^([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$", var.domain)) == 1
    error_message = "The `domain` variable must be a valid domain, and match the regex: ^([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$."
  }
}

variable "hosted_zone_id" {
  description = "The ID of the Route53 hosted zone to publish verification, DKIM, SPF, and DMARC records in."
  type        = string
}

variable "mail_from_configuration" {
  description = "Configuration for the MAIL FROM domain to configure for SES. `domain` and `hosted_zone_id` are required keys in this map. `domain` defaults to `mail.{domain variable}` and `hosted_zone_id` defaults to the `hosted_zone_id` variable."
  type = object({
    domain         = string
    hosted_zone_id = string
  })
  default = null

  validation {
    condition     = var.mail_from_configuration == null ? true : length(regexall("^([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$", var.mail_from_configuration.domain)) == 1
    error_message = "The `mail_from_configuration.domain` variable must be a valid domain, and match the regex: ^([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$."
  }
}

variable "dmarc_configuration" {
  description = <<EOF
  Configuration for DMARC on this domain. If not provided, no DMARC record will be created.
  `aggregate_report_address`: The email address to send DMARC aggregate reports to (DMARC 'rua' tag).
  `dkim_alignment_mode`: The alignment mode for DKIM verification (DMARC 'adkim' tag). Options are 'r' (relaxed) or 's' (strict).
  `failure_reporting_options`: A list of failure reporting options (DMARC 'fo' tag). Options are `0`, `1`, `d`, and `s`.
  `forensic_report_address`: The email address to send DMARC forensic reports to (DMARC 'ruf' tag).
  `percentage`: The percentage (0 - 100) of mail received from this domain that should be marked as spam (DMARC 'pct' tag).
  `policy`: The DMARC policy to apply to messages that fail (DMARC 'p' tag). Options are `none`, `quarantine`, or `reject`.
  `report_interval_seconds`: The DMARC reporting interval, in seconds (DMARC 'ri' tag).
  `subdomain_policy`: The DMARC policy to apply to subdomains of this mail domain. Options are `none`, `quarantine`, or `reject`.

  Note that the 'v' (version) tag is fixed as 'DMARC1' and the 'rf' (report format) tag is fixed as 'afrf' as these are the only supported values.
  The 'aspf' (SPF alignment mode) tag is fixed as 'r' (relaxed) since SES does not allow the MAIL FROM domain to be the same as the HEADER FROM domain.
EOF
  type = object({
    aggregate_report_address  = string
    dkim_alignment_mode       = string
    failure_reporting_options = list(string)
    forensic_report_address   = string
    percentage                = number
    policy                    = string
    report_interval_seconds   = string
    subdomain_policy          = string
  })

  validation {
    condition     = var.dmarc_configuration == null ? true : length(regexall("^[0-9a-zA-Z!#$%&'*+\\/=?^_`{|}~.-]+@([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$", var.dmarc_configuration.aggregate_report_address)) == 1
    error_message = "The `dmarc_configuration.aggregate_report_address` variable must be a valid email address, and match the regex: ^[0-9a-zA-Z!#$%&'*+/=?^_`{|}~.-]@([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : length(regexall("^[0-9a-zA-Z!#$%&'*+\\/=?^_`{|}~.-]+@([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$", var.dmarc_configuration.forensic_report_address)) == 1
    error_message = "The `dmarc_configuration.forensic_report_address` variable must be a valid email address, and match the regex: ^[0-9a-zA-Z!#$%&'*+/=?^_`{|}~.-]@([a-z0-9]+[a-z0-9-]*\\.)+[a-z]{2,}$."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : var.dmarc_configuration.report_interval_seconds >= 86400
    error_message = "The `dmarc_configuration.report_interval_seconds` variable must at least 86400 (1 day)."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : var.dmarc_configuration.percentage >= 0 && var.dmarc_configuration.percentage <= 100
    error_message = "The `dmarc_configuration.percentage` variable must be between 0 and 100."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : contains(["none", "quarantine", "reject"], var.dmarc_configuration.policy)
    error_message = "The `dmarc_configuration.policy` variable must be 'none', 'quarantine', or 'reject'."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : contains(["none", "quarantine", "reject"], var.dmarc_configuration.subdomain_policy)
    error_message = "The `dmarc_configuration.subdomain_policy` variable must be 'none', 'quarantine', or 'reject'."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : length(distinct(var.dmarc_configuration.failure_reporting_options)) == length(var.dmarc_configuration.failure_reporting_options)
    error_message = "The `dmarc_configuration.failure_reporting_options` variable must not contain any duplicate values."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : length(setsubtract(var.dmarc_configuration.failure_reporting_options, ["0", "1", "d", "s"])) == 0
    error_message = "The `dmarc_configuration.failure_reporting_options` variable must only contain the values '0', '1', 'd', or 's'."
  }

  validation {
    condition     = var.dmarc_configuration == null ? true : contains(["r", "s"], var.dmarc_configuration.dkim_alignment_mode)
    error_message = "The `dmarc_configuration.dkim_alignment_mode` variable must be 'r' or 's'."
  }
}
