<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Usage

Creates an Amazon OpenSearch Service domain with secure defaults.  This module always requires node-to-node encryption, encryption at rest, HTTPS endpoints, and use of a VPC.

```hcl
module "opensearch_kms_key" {
  source = "dod-iac/opensearch-kms-key/aws"

  name = format("alias/app-%s-opensearch-%s", var.application, var.environment)
  description = format("A KMS key used to encrypt data in Amazon OpenSearch Service for %s:%s.", var.application, var.environment)
  principals = ["*"]
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}

module "opensearch_domain" {
  source = "dod-iac/opensearch-domain/aws"

  name = format("app-%s-%s", var.application, var.environment)
  kms_key_arn = module.opensearch_kms_key.aws_kms_key_arn
  ingress_cidr_blocks  = ["0.0.0.0/0"]
  subnet_ids = slice(module.vpc.private_subnets, 0, 1)
  vpc_id = module.vpc.vpc_id
  tags = {
    Application = var.application
    Environment = var.environment
    Automation  = "Terraform"
  }
}
```

The IAM service-linked role for Amazon OpenSearch Service is required before you can create a domain.  If the role does not exist, then you can create the role with the following resource.

```hcl
resource "aws_iam_service_linked_role" "main" {
  aws_service_name = "opensearchservice.amazonaws.com"
}
```

## Terraform Version

Terraform 0.13. Pin module version to ~> 1.0.0 . Submit pull-requests to main branch.

Terraform 0.11 and 0.12 are not supported.

## License

This project constitutes a work of the United States Government and is not subject to domestic copyright protection under 17 USC § 105.  However, because the project utilizes code licensed from contributors and other third parties, it therefore is licensed under the MIT License.  See LICENSE file for more information.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.26.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.26.0, < 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_opensearch_domain.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearch_domain) | resource |
| [aws_security_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_cidr_blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.access_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies) | IAM policy document specifying the access policies for the domain.  If not specified, then access is open to all principals. | `string` | `""` | no |
| <a name="input_automated_snapshot_start_hour"></a> [automated\_snapshot\_start\_hour](#input\_automated\_snapshot\_start\_hour) | Hour during which the service takes an automated daily snapshot of the indices in the domain. | `string` | `23` | no |
| <a name="input_cold_enabled"></a> [cold\_enabled](#input\_cold\_enabled) | Enable cold storage for the domain to store infrequently accessed or historical data.  Requires `dedicated_master_enabled` and `warm_enabled` to also be true. | `bool` | `false` | no |
| <a name="input_dedicated_master_count"></a> [dedicated\_master\_count](#input\_dedicated\_master\_count) | Number of dedicated master nodes in the cluster.  The value must be the number 3 or 5.  For production domains, 3 is recommended. | `number` | `3` | no |
| <a name="input_dedicated_master_enabled"></a> [dedicated\_master\_enabled](#input\_dedicated\_master\_enabled) | Use dedicated master nodes with the Amazon OpenSearch Service domain. | `bool` | `false` | no |
| <a name="input_dedicated_master_instance_type"></a> [dedicated\_master\_instance\_type](#input\_dedicated\_master\_instance\_type) | Instance type of the dedicated main nodes in the cluster.  If not provided, then defaults to the value of the "instance\_type" variable. | `string` | `""` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Either Elasticsearch\_X.Y or OpenSearch\_X.Y to specify the engine version for the Amazon OpenSearch Service domain. For example, OpenSearch\_1.3 or Elasticsearch\_7.9. | `string` | `"OpenSearch_1.3"` | no |
| <a name="input_fielddata_cache_size"></a> [fielddata\_cache\_size](#input\_fielddata\_cache\_size) | Specifies the percentage of heap space that is allocated to fielddata. The value must be a number between 0 and 100. | `number` | `20` | no |
| <a name="input_ingress_cidr_blocks"></a> [ingress\_cidr\_blocks](#input\_ingress\_cidr\_blocks) | A list of CIDR blocks to allow access to the Amazon OpenSearch Service domain.  Use ["0.0.0.0/0"] to allow all connections within the VPC. | `list(string)` | `[]` | no |
| <a name="input_ingress_security_groups"></a> [ingress\_security\_groups](#input\_ingress\_security\_groups) | A list of EC2 security groups to allow access to the Amazon OpenSearch Service domain. | `list(string)` | `[]` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of instances in the cluster. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of data nodes in the cluster. | `string` | `"r6g.large.search"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The KMS key ARN to encrypt the Amazon OpenSearch Service domain with. If not specified, then it defaults to using the AWS-managed aws/es key. | `string` | `""` | no |
| <a name="input_max_clause_count"></a> [max\_clause\_count](#input\_max\_clause\_count) | Specifies the maximum number of allowed boolean clauses in a query. The number must be between 1 and 2147483647. | `number` | `1024` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Amazon OpenSearch Service domain. | `string` | n/a | yes |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | The name of the EC2 security group used by the Amazon OpenSearch Service domain.  Defaults to opensearch-[name]. | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC Subnet IDs for the Amazon OpenSearch Service domain endpoints to be created in. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Amazon OpenSearch Service domain. | `map(string)` | `{}` | no |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy) | The name of the TLS security policy that needs to be applied to the HTTPS endpoint. Valid values: Policy-Min-TLS-1-0-2019-07 and Policy-Min-TLS-1-2-2019-07. | `string` | `"Policy-Min-TLS-1-2-2019-07"` | no |
| <a name="input_volume_iops"></a> [volume\_iops](#input\_volume\_iops) | Baseline input/output (I/O) performance of EBS volumes attached to data nodes.  Applicable only for the gp3 volume type. Valid values are between `3000` and `16000`. | `number` | `3000` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of EBS volumes attached to data nodes (in GB). | `number` | `20` | no |
| <a name="input_volume_throughput"></a> [volume\_throughput](#input\_volume\_throughput) | Specifies the throughput (in MiB/s) of the EBS volumes attached to data nodes. Applicable only for the gp3 volume type. Valid values are between `125` and `1000`. | `number` | `125` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | The type of EBS volumes attached to data nodes. | `string` | `"gp3"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC that the security group for the Amazon OpenSearch Service domain will be associated with. | `string` | n/a | yes |
| <a name="input_warm_count"></a> [warm\_count](#input\_warm\_count) | Number of warm nodes in the cluster. Valid values are between 2 and 150. | `number` | `3` | no |
| <a name="input_warm_enabled"></a> [warm\_enabled](#input\_warm\_enabled) | Enable UltraWarm data nodes for the domain to economically retain large amounts of data. | `bool` | `false` | no |
| <a name="input_warm_instance_type"></a> [warm\_instance\_type](#input\_warm\_instance\_type) | Instance type for the domain's warm nodes. Valid values are `ultrawarm1.medium.search`, `ultrawarm1.large.search` and `ultrawarm1.xlarge.search`. | `string` | `"ultrawarm1.medium.search"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the Amazon OpenSearch Service domain. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests. |
| <a name="output_id"></a> [id](#output\_id) | The id of the Amazon OpenSearch Service domain. |
| <a name="output_kibana_endpoint"></a> [kibana\_endpoint](#output\_kibana\_endpoint) | Domain-specific endpoint for kibana without https scheme. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Amazon OpenSearch Service domain. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
