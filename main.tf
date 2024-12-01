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
  source            = "./modules/ecs-cluster"
  cluster_name      = "road-vision-cluster"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = "t2.micro"
  desired_capacity  = 2
  min_size          = 0
  max_size          = 4
  key_pair_name     = var.key_pair_name
  alb_security_group_id      = module.lb.alb_security_group_id
  allowed_ports              = var.allowed_ports
}

module "lb" {
  source         = "./modules/lb"
  vpc_id         = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "mqtt" {
  source                             = "./modules/mqtt"
  ecs_cluster_id                     = module.ecs_cluster.ecs_cluster_id
  ecs_task_execution_role            = module.ecs_cluster.ecs_task_execution_role_arn
  public_subnet_ids                  = module.vpc.public_subnet_ids
  service_discovery_namespace_id     = module.ecs_cluster.service_discovery_namespace_id
  vpc_id                             = module.vpc.vpc_id
  ecs_instance_security_group_id     = module.ecs_cluster.ecs_instance_security_group_id
}

module "redis" {
  source                             = "./modules/redis"
  ecs_cluster_id                     = module.ecs_cluster.ecs_cluster_id
  ecs_task_execution_role            = module.ecs_cluster.ecs_task_execution_role_arn
  public_subnet_ids                  = module.vpc.public_subnet_ids
  service_discovery_namespace_id     = module.ecs_cluster.service_discovery_namespace_id
  vpc_id                             = module.vpc.vpc_id
  ecs_instance_security_group_id     = module.ecs_cluster.ecs_instance_security_group_id
}
