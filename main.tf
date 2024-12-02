# Include the child modules

module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/security-groups"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  allowed_ports = var.allowed_ports
}

module "rds" {
  source       = "./modules/rds"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  db_username  = var.db_username
  db_password  = var.db_password
  rds_sg_id = module.security_groups.rds_sg_id
}

module "ecs_cluster" {
  source            = "./modules/ecs-cluster"
  cluster_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = "t2.micro"
  desired_capacity  = 2
  min_size          = 0
  max_size          = 4
  key_pair_name     = var.key_pair_name
  rds_sg_id = module.security_groups.rds_sg_id
  alb_sg_id = module.security_groups.alb_sg_id
  ecs_instances_sg_id = module.security_groups.ecs_instances_sg_id
  allowed_ports              = var.allowed_ports
}

module "lb" {
  source         = "./modules/lb"
  vpc_id         = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id = module.security_groups.alb_sg_id
}

module "mqtt" {
  source                             = "./modules/mqtt"
  ecs_cluster_id                     = module.ecs_cluster.ecs_cluster_id
  ecs_task_execution_role            = module.ecs_cluster.ecs_task_execution_role_arn
  public_subnet_ids                  = module.vpc.public_subnet_ids
  service_discovery_namespace_id     = module.ecs_cluster.service_discovery_namespace_id
  vpc_id                             = module.vpc.vpc_id
  ecs_instances_sg_id = module.security_groups.ecs_instances_sg_id
  mqtt_sg = module.security_groups.mqtt_sg_id
}

module "redis" {
  source                             = "./modules/redis"
  ecs_cluster_id                     = module.ecs_cluster.ecs_cluster_id
  ecs_task_execution_role            = module.ecs_cluster.ecs_task_execution_role_arn
  public_subnet_ids                  = module.vpc.public_subnet_ids
  service_discovery_namespace_id     = module.ecs_cluster.service_discovery_namespace_id
  vpc_id                             = module.vpc.vpc_id
  redis_sg_id = module.security_groups.redis_sg_id
  ecs_instances_sg_id = module.security_groups.ecs_instances_sg_id
}
