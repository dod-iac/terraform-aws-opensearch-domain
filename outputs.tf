output "arn" {
  description = "The ARN of the Amazon OpenSearch Service domain."
  value       = aws_opensearch_domain.main.arn
}

output "id" {
  description = "The id of the Amazon OpenSearch Service domain."
  value       = aws_opensearch_domain.main.domain_id
}

output "name" {
  description = "The name of the Amazon OpenSearch Service domain."
  value       = aws_opensearch_domain.main.domain_name
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests."
  value       = aws_opensearch_domain.main.endpoint
}

output "kibana_endpoint" {
  description = "Domain-specific endpoint for kibana without https scheme."
  value       = aws_opensearch_domain.main.kibana_endpoint
}
