# Include the child modules

module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/security-groups"
  cluster_name = var.cluster_name
  vpc_id = module.vpc.vpc_id
  allowed_ports = var.allowed_ports
  my_ip = var.my_ip
}

module "rds" {
  source       = "./modules/rds"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.public_subnet_ids
  db_username  = var.db_username
  db_password  = var.db_password
  rds_sg_id    = module.security_groups.rds_sg_id
}

module "ecs_cluster" {
  source            = "./modules/ecs-cluster"
  cluster_name      = var.cluster_name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = "t2.micro"
  desired_capacity  = 1
  min_size          = 1
  max_size          = 2
  key_pair_name     = var.key_pair_name
  rds_sg_id = module.security_groups.rds_sg_id
  alb_sg_id = module.security_groups.alb_sg_id
  ecs_instances_sg_id = module.security_groups.ecs_instances_sg_id
  allowed_ports              = var.allowed_ports
  efs_access_policy_arn = module.efs.efs_access_policy_arn
}

module "lb" {
  source         = "./modules/lb"
  vpc_id         = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id = module.security_groups.alb_sg_id
}

module "efs" {
  source = "./modules/efs"
  efs_subnet_ids = module.vpc.public_subnet_ids
  efs_security_group_ids = [module.security_groups.efs_sg_id]
}

module "mqtt" {
  source                             = "./modules/mqtt"
  ecs_cluster_id                     = module.ecs_cluster.ecs_cluster_id
  ecs_cluster_name                   = module.ecs_cluster.ecs_cluster_name
  ecs_task_execution_role            = module.ecs_cluster.ecs_task_execution_role_arn
  public_subnet_ids                  = module.vpc.public_subnet_ids
  service_discovery_namespace_id     = module.ecs_cluster.service_discovery_namespace_id
  vpc_id                             = module.vpc.vpc_id
  ecs_instances_sg_id = module.security_groups.ecs_instances_sg_id
  mqtt_sg = module.security_groups.mqtt_sg_id
  mqtt_tg_arn = module.lb.mqtt_tg_blue_arn
  mqtt_tg_blue_name = module.lb.mqtt_tg_blue_name
  mqtt_tg_green_name = module.lb.mqtt_tg_green_name
  efs_file_system_id = module.efs.efs_file_system_id
  codedeploy_role_arn = aws_iam_role.codedeploy_role.arn
  alb_mqtt_listener_arn = module.lb.alb_mqtt_listener_arn
  alb_mqtt_test_listener_arn = module.lb.alb_mqtt_test_listener_arn
  ecs_asg_id = module.ecs_cluster.ecs_asg_id
  aws_region = var.aws_region
}

module "elasticache" {
  source                    = "./modules/elasticache"
  subnet_ids                = module.vpc.private_subnet_ids
  vpc_id                    = module.vpc.vpc_id
  security_group_ids        = module.security_groups.redis_sg_id
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
