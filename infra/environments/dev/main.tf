module "vpc" {
  source = "../../modules/network/vpc"

  name     = "test-app"
  vpc_cidr = "10.0.0.0/16"

  azs = ["eu-north-1a", "eu-north-1b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
}
