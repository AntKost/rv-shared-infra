# Include the child modules

module "vpc" {
  source = "./modules/vpc"
}

module "rds" {
  source       = "./modules/rds"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  db_username  = var.db_username
  db_password  = var.db_password
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"
}

module "lb" {
  source         = "./modules/lb"
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnet_ids
}

module "mqtt" {
  vpc_id                  = module.vpc.vpc_id
  source                  = "./modules/mqtt"
  ecs_cluster_id          = module.ecs_cluster.ecs_cluster_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  ecs_task_execution_role = module.ecs_cluster.ecs_task_execution_role
}

module "redis" {
  vpc_id                  = module.vpc.vpc_id
  source                  = "./modules/redis"
  ecs_cluster_id          = module.ecs_cluster.ecs_cluster_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  ecs_task_execution_role = module.ecs_cluster.ecs_task_execution_role
}
