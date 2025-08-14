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

module "topics" {
  source = "./topics"
  
  bootstrap_servers = module.msk_cluster.bootstrap_brokers_tls
  kafka_username    = var.msk_scram_username
  kafka_password    = var.msk_scram_password
  environment       = var.environment
  
  depends_on = [module.msk_cluster]
}