locals {
  azs = (var.availability_zones_count > 0) ? slice(data.aws_availability_zones.available.names, 0, min(var.availability_zones_count, length(data.aws_availability_zones.available.names))) : var.availability_zones
  calculated_public_subnets = length(var.public_subnets) > 0 ? var.public_subnets : [for k, v in local.azs : cidrsubnet(var.cidr, 4, k)]
  calculated_private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : [for k, v in local.azs : cidrsubnet(var.cidr, 4, k + 6)]
}

data "aws_availability_zones" "available" {}

################################################################################
# Providers
################################################################################

provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "cluster-data" {
  name = module.eks.name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "cluster-auth" {
  name = module.eks.name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-data.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster-auth.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster-data.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster-auth.token
  }
}


################################################################################
# Common resources
################################################################################

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

resource "null_resource" "validations" {
  lifecycle {
    precondition {
      condition     = !(var.availability_zones_count == 0 && length(var.availability_zones) == 0)
      error_message = "The variable availability_zones_count must be set if availability_zones is not set"
    }

    precondition {
      condition     = !(var.create_vpc == false && length(var.private_subnets) == 0)
      error_message = "The variable private_subnets must be set if create_vpc is false"
    }

    precondition {
      condition     = !(var.create_vpc == false && length(var.public_subnets) == 0)
      error_message = "The variable public_subnets must be set if create_vpc is false"
    }
  }
}

################################################################################
# VPC
################################################################################
module "vpc" {
  depends_on = [
    null_resource.validations
  ]
  create_vpc = var.create_vpc

  source  = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "devzero-${terraform.workspace}-${random_string.this.result}-vpc"
  cidr = var.cidr

  azs             = local.azs
  public_subnets  = local.calculated_public_subnets
  private_subnets = local.calculated_private_subnets


  enable_nat_gateway = true
  single_nat_gateway = true

  default_security_group_egress = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  default_security_group_ingress = [
    {
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = join(",", local.calculated_private_subnets)
    }
  ]
}

################################################################################
# EKS
################################################################################

# We call EKS module to ensure compatibility
module "eks" {
  providers = {
    aws = aws
  }

  source = "../../../modules/aws/eks"

  cluster_name = "${terraform.workspace}-${random_string.this.result}-eks"

  region               = var.region
  environment          = var.environment
  security_group_ids   = [module.vpc.default_security_group_id]
  subnet_ids           = module.vpc.private_subnets
  desired_node_size    = var.desired_node_size
  max_node_size        = var.max_node_size
  min_node_size        = var.desired_node_size
  worker_instance_type = var.worker_instance_type
}

# Data source to get the AWS account ID
data "aws_caller_identity" "current" {}

# Construct the OIDC provider ARN using the cluster OIDC URL and the account ID
locals {
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
}

module "ebs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${module.eks.name}-ebs-csi-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = local.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

################################################################################
# EKS Blueprints Addons
################################################################################

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.name
  cluster_endpoint  = module.eks.endpoint
  cluster_version   = module.eks.version
  oidc_provider_arn = module.eks.provider_id

  tags = {
    Terraform = "true"
  }
}

################################################################################
# GP3 default
################################################################################

resource "kubernetes_annotations" "gp2_default" {
  annotations = {
    "storageclass.kubernetes.io/is-default-class" : "false"
  }
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }

  force = true

  depends_on = [module.eks_blueprints_addons]
}

resource "kubernetes_storage_class" "ebs_csi_encrypted_gp3_storage_class" {
  metadata {
    name = "ebs-csi-encrypted-gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    fsType    = "ext4"
    encrypted = true
    type      = "gp3"
  }

  depends_on = [kubernetes_annotations.gp2_default]
}

################################################################################
# EFS
################################################################################

module "efs" {
  providers = {
    aws        = aws
    kubernetes = kubernetes
    helm       = helm
  }

  source = "../../../modules/aws/efs"

  efs_enabled = true

  environment = var.environment

  efs_pv_name            = "${terraform.workspace}-${random_string.this.result}-efs-pv"
  efs_sc_name            = "${terraform.workspace}-${random_string.this.result}-efs-csi-sc"
  efs_claim_name         = "${terraform.workspace}-${random_string.this.result}-efs-csi-claim"
  efs_driver_name        = "${terraform.workspace}-${random_string.this.result}-efs-csi-driver"
  efs_controller_sa_name = "${terraform.workspace}-${random_string.this.result}-efs-csi-controller-sa"

  cluster_name               = module.eks.name
  cluster_endpoint           = module.eks.endpoint
  cluster_ca_certificate     = module.eks.cluster_ca_certificate
  aws_eks_cluster_auth_token = module.eks.aws_eks_cluster_auth_token
  provider_url               = module.eks.provider_url

  security_group_ids = [module.vpc.default_security_group_id]
  app_subnet_id_01   = module.vpc.private_subnets[0]
  app_subnet_id_02   = module.vpc.private_subnets[1]

  depends_on = [module.eks]
}

################################################################################
# Vault
################################################################################

resource "aws_kms_key" "vault-auto-unseal" {
  description = "Vault auto unseal keys"

  deletion_window_in_days = 10
}

resource "aws_kms_alias" "vault-auto-unseal" {
  name          = "alias/vault-auto-unseal"
  target_key_id = aws_kms_key.vault-auto-unseal.key_id
}

resource "aws_kms_key_policy" "vault-auto-unseal" {
  key_id = aws_kms_key.vault-auto-unseal.id
  policy = jsonencode({
    Id = "vault-auto-unseal"
    Statement = [
      {
        Action = [
          "kms:*",
          #          "kms:Decrypt",
          #          "kms:DescribeKey",
        ]
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }

        Resource = "*"
        Sid      = "Enable IAM User Permissions for auto unsealing vault: (vault)"
      },
    ]
    Version = "2012-10-17"
  })
}
