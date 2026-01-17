output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "server_log_group_name" {
  value = module.logs.server_log_group_name
}

output "consumer_log_group_name" {
  value = module.logs.consumer_log_group_name
}

output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}

output "ecs_execution_role_arn" {
  value = module.iam.execution_role_arn
}

output "ecs_task_role_arn" {
  value = module.iam.task_role_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecs_sg_id" {
  value = module.alb.ecs_sg_id
}

output "target_group_arn" {
  value = module.alb.target_group_arn
}

output "ecs_cluster_name" {
  value = module.ecs_server.cluster_name
}

output "ecs_server_service_name" {
  value = module.ecs_server.service_name
}

output "client_bucket_name" {
  value = module.client_bucket.bucket_name
}

output "cloudfront_domain_name" {
  value = module.cloudfront.cloudfront_domain_name
}

output "sqs_queue_url" {
  value = module.sqs.queue_url
}


output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}