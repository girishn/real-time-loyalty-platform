module "msk_cluster" {
  source = "./msk_cluster"
  cluster_name = var.cluster_name
  msk_scram_username = var.msk_scram_username
  msk_scram_password = var.msk_scram_password
}

module "ec2_client" {
  source = "./ec2_client"
  environment = var.environment
}