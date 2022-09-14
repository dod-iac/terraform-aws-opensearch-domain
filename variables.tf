variable "access_policies" {
  type        = string
  description = "IAM policy document specifying the access policies for the domain.  If not specified, then access is open to all principals."
  default     = ""
}

variable "automated_snapshot_start_hour" {
  type        = string
  description = "Hour during which the service takes an automated daily snapshot of the indices in the domain."
  default     = 23
}

variable "cold_enabled" {
  type        = bool
  description = "Enable cold storage for the domain to store infrequently accessed or historical data.  Requires `dedicated_master_enabled` and `warm_enabled` to also be true."
  default     = false
}

variable "dedicated_master_count" {
  type        = number
  description = "Number of dedicated master nodes in the cluster.  The value must be the number 3 or 5.  For production domains, 3 is recommended."
  default     = 3
}

variable "dedicated_master_enabled" {
  type        = bool
  description = "Use dedicated master nodes with the Amazon OpenSearch Service domain."
  default     = false
}

variable "dedicated_master_instance_type" {
  type        = string
  description = "Instance type of the dedicated main nodes in the cluster.  If not provided, then defaults to the value of the \"instance_type\" variable."
  default     = ""
}

variable "ingress_cidr_blocks" {
  type        = list(string)
  description = "A list of CIDR blocks to allow access to the Amazon OpenSearch Service domain.  Use [\"0.0.0.0/0\"] to allow all connections within the VPC."
  default     = []
}

variable "ingress_security_groups" {
  type        = list(string)
  description = "A list of EC2 security groups to allow access to the Amazon OpenSearch Service domain."
  default     = []
}

variable "name" {
  type        = string
  description = "Name of the Amazon OpenSearch Service domain."
}

variable "engine_version" {
  type        = string
  description = "Either Elasticsearch_X.Y or OpenSearch_X.Y to specify the engine version for the Amazon OpenSearch Service domain. For example, OpenSearch_1.3 or Elasticsearch_7.9."
  default     = "OpenSearch_1.3"
}

variable "fielddata_cache_size" {
  type        = number
  description = "Specifies the percentage of heap space that is allocated to fielddata. The value must be a number between 0 and 100."
  default     = 20
}

variable "instance_count" {
  type        = number
  description = "Number of instances in the cluster."
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "Instance type of data nodes in the cluster."
  default     = "r6g.large.search"
}

variable "kms_key_arn" {
  type        = string
  description = "The KMS key ARN to encrypt the Amazon OpenSearch Service domain with. If not specified, then it defaults to using the AWS-managed aws/es key."
  default     = ""
}

variable "max_clause_count" {
  type        = number
  description = "Specifies the maximum number of allowed boolean clauses in a query. The number must be between 1 and 2147483647."
  default     = 1024
}

variable "security_group_name" {
  type        = string
  description = "The name of the EC2 security group used by the Amazon OpenSearch Service domain.  Defaults to opensearch-[name]."
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC Subnet IDs for the Amazon OpenSearch Service domain endpoints to be created in."
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Amazon OpenSearch Service domain."
  default     = {}

}
variable "tls_security_policy" {
  type        = string
  description = "The name of the TLS security policy that needs to be applied to the HTTPS endpoint. Valid values: Policy-Min-TLS-1-0-2019-07 and Policy-Min-TLS-1-2-2019-07."
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "volume_iops" {
  type        = number
  description = "Baseline input/output (I/O) performance of EBS volumes attached to data nodes.  Applicable only for the gp3 volume type. Valid values are between `3000` and `16000`."
  default     = 3000
}

variable "volume_size" {
  type        = number
  description = "The size of EBS volumes attached to data nodes (in GB)."
  default     = 20
}

variable "volume_throughput" {
  type        = number
  description = "Specifies the throughput (in MiB/s) of the EBS volumes attached to data nodes. Applicable only for the gp3 volume type. Valid values are between `125` and `1000`."
  default     = 125
}

variable "volume_type" {
  type        = string
  description = "The type of EBS volumes attached to data nodes."
  default     = "gp3"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC that the security group for the Amazon OpenSearch Service domain will be associated with."
}

variable "warm_enabled" {
  type        = bool
  description = "Enable UltraWarm data nodes for the domain to economically retain large amounts of data."
  default     = false
}

variable "warm_count" {
  type        = number
  description = "Number of warm nodes in the cluster. Valid values are between 2 and 150."
  default     = 3
}

variable "warm_instance_type" {
  type        = string
  description = "Instance type for the domain's warm nodes. Valid values are `ultrawarm1.medium.search`, `ultrawarm1.large.search` and `ultrawarm1.xlarge.search`."
  default     = "ultrawarm1.medium.search"
}
