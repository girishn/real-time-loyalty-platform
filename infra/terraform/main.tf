module "msk_cluster" {
  source = "./msk_cluster"
  cluster_name = var.cluster_name
  msk_scram_username = var.msk_scram_username
  msk_scram_password = var.msk_scram_password
}

module "ec2_client" {
  source = "./ec2_client"
  environment = var.environment
  msk_scram_secret_arn = module.msk_cluster.msk_scram_secret_arn

  depends_on = [module.msk_cluster]
}

module "managed_flink" {
  source = "./managed_flink"

  environment        = "dev"
  application_name   = "points-fraud-processor"
  msk_cluster_name   = module.msk_cluster.msk_cluster_name
  msk_cluster_arn    = module.msk_cluster.msk_cluster_arn
  private_subnet_ids    = module.msk_cluster.private_subnet_ids
  msk_security_group_id = module.msk_cluster.msk_security_group_id
  kafka_username     = var.msk_scram_username
  kafka_password     = var.msk_scram_password

  depends_on = [module.msk_cluster]
}