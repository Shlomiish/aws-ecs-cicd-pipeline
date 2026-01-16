module "vpc" {
  source = "../../modules/network/vpc"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "logs" {
  source = "../../modules/observability/cloudwatch_logs"

  name              = var.name
  retention_in_days = var.log_retention_days
}


module "ecr" {
  source = "../../modules/compute/ecr"

  name         = var.name
  repositories = var.ecr_repositories

  image_tag_mutability = "IMMUTABLE"
  scan_on_push         = true
}

module "iam" {
  source = "../../modules/security/iam"
  name   = var.name
}

module "alb" {
  source = "../../modules/loadbalancing/alb"

  name              = var.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  server_port       = var.server_port
}


module "sqs" {
  source = "../../modules/messaging/sqs"
  name   = var.name
}

module "ecs_server" {
  source = "../../modules/compute/ecs_service"

  name              = var.name
  region            = var.aws_region
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.alb.ecs_sg_id

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  ecr_image        = var.server_image
  container_port   = var.server_port
  log_group_name   = module.logs.server_log_group_name
  target_group_arn = module.alb.target_group_arn

  desired_count = var.server_desired_count

  environment = {
    AWS_REGION    = var.aws_region
    SQS_QUEUE_URL = module.sqs.queue_url
  }

}

module "ecs_consumer" {
  source = "../../modules/compute/ecs_worker"

  name   = var.name
  region = var.aws_region

  cluster_id        = module.ecs_server.cluster_name
  subnet_ids        = module.vpc.private_subnet_ids
  security_group_id = module.alb.ecs_sg_id

  execution_role_arn = module.iam.execution_role_arn
  task_role_arn      = module.iam.task_role_arn

  ecr_image      = var.consumer_image
  log_group_name = module.logs.consumer_log_group_name

  desired_count = var.consumer_desired_count

  environment = {
    AWS_REGION    = var.aws_region
    SQS_QUEUE_URL = module.sqs.queue_url
  }


}


module "client_bucket" {
  source = "../../modules/edge/s3_static_site"

  bucket_name = var.client_bucket_name
}

module "cloudfront" {
  source = "../../modules/edge/cloudfront"

  name                        = var.name
  alb_dns_name                = module.alb.alb_dns_name
  bucket_name                 = module.client_bucket.bucket_name
  bucket_arn                  = module.client_bucket.bucket_arn
  bucket_regional_domain_name = module.client_bucket.bucket_regional_domain_name
}




resource "aws_iam_role_policy" "sqs_access" {
  name = "${var.name}-sqs-access"
  role = module.iam.task_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = module.sqs.queue_arn
    }]
  })
}
