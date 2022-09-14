/**
 * ## Usage
 *
 * Creates an Amazon OpenSearch Service domain with secure defaults.  This module always requires node-to-node encryption, encryption at rest, HTTPS endpoints, and use of a VPC.
 *
 *
 * ```hcl
 * module "opensearch_kms_key" {
 *   source = "dod-iac/opensearch-kms-key/aws"
 *
 *   name = format("alias/app-%s-opensearch-%s", var.application, var.environment)
 *   description = format("A KMS key used to encrypt data in Amazon OpenSearch Service for %s:%s.", var.application, var.environment)
 *   principals = ["*"]
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 *
 * module "opensearch_domain" {
 *   source = "dod-iac/opensearch-domain/aws"
 *
 *   name = format("app-%s-%s", var.application, var.environment)
 *   kms_key_arn = module.opensearch_kms_key.aws_kms_key_arn
 *   ingress_cidr_blocks  = ["0.0.0.0/0"]
 *   subnet_ids = slice(module.vpc.private_subnets, 0, 1)
 *   vpc_id = module.vpc.vpc_id
 *   tags = {
 *     Application = var.application
 *     Environment = var.environment
 *     Automation  = "Terraform"
 *   }
 * }
 * ```
 *
 * The IAM service-linked role for Amazon OpenSearch Service is required before you can create a domain.  If the role does not exist, then you can create the role with the following resource.
 *
 * ```hcl
 * resource "aws_iam_service_linked_role" "main" {
 *   aws_service_name = "opensearchservice.amazonaws.com"
 * }
 * ```
 *
 * ## Terraform Version
 *
 * Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.
 *
 * Terraform 0.11 and 0.12 are not supported.
 *
 * ## License
 *
 * This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.
 */

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_security_group" "main" {
  name        = length(var.security_group_name) > 0 ? var.security_group_name : format("opensearch-%s", var.name)
  description = "Security group for Amazon OpenSearch Service domain"
  tags        = var.tags
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count = length(var.ingress_cidr_blocks) > 0 ? 1 : 0

  security_group_id = aws_security_group.main.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  cidr_blocks = var.ingress_cidr_blocks
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count = length(var.ingress_security_groups)

  security_group_id = aws_security_group.main.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"

  source_security_group_id = var.ingress_security_groups[count.index]
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.main.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

data "aws_iam_policy_document" "access_policies" {
  statement {
    actions = [
      "es:*"
    ]
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      format(
        "arn:%s:es:%s:%s:domain/%s/*",
        data.aws_partition.current.partition,
        data.aws_region.current.name,
        data.aws_caller_identity.current.account_id,
        var.name
      )
    ]
  }
}

resource "aws_opensearch_domain" "main" {

  access_policies = length(var.access_policies) > 0 ? var.access_policies : data.aws_iam_policy_document.access_policies.json

  advanced_options = {
    "indices.fielddata.cache.size"        = tostring(var.fielddata_cache_size)
    "indices.query.bool.max_clause_count" = tostring(var.max_clause_count)
  }

  advanced_security_options {
    enabled                        = false
    internal_user_database_enabled = false
    master_user_options {
      master_user_arn      = null
      master_user_name     = null
      master_user_password = null
    }
  }

  auto_tune_options {
    desired_state       = "DISABLED"
    rollback_on_disable = "NO_ROLLBACK"
  }

  cluster_config {
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_enabled ? var.dedicated_master_count : null
    dedicated_master_type    = var.dedicated_master_enabled ? coalesce(var.dedicated_master_instance_type, var.instance_type) : null
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    warm_count               = var.warm_enabled ? var.warm_count : null
    warm_enabled             = false
    warm_type                = var.warm_enabled ? var.warm_instance_type : null

    cold_storage_options {
      enabled = var.dedicated_master_enabled && var.warm_enabled && var.cold_enabled
    }
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = var.tls_security_policy
  }

  domain_name = var.name

  ebs_options {
    ebs_enabled = true
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.volume_type == "gp3" ? var.volume_iops : null
    throughput  = var.volume_type == "gp3" ? var.volume_throughput : null
  }

  engine_version = var.engine_version

  encrypt_at_rest {
    enabled = true
    # Note that KMS will accept a KMS key ID but will return the key ARN.
    # To prevent Terraform detecting unwanted changes, use the key ARN instead.
    kms_key_id = var.kms_key_arn
  }

  node_to_node_encryption {
    enabled = true
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  tags = var.tags

  vpc_options {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.main.id]
  }
}
