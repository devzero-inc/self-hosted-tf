locals {
  azs = (var.availability_zones_count > 0) ? slice(data.aws_availability_zones.available.names, 0, min(var.availability_zones_count, length(data.aws_availability_zones.available.names))) : var.availability_zones

  calculated_public_subnets_ids = length(var.public_subnet_ids) > 0 ? var.public_subnet_ids : module.vpc.public_subnets
  calculated_private_subnets_ids = length(var.private_subnet_ids) > 0 ? var.private_subnet_ids : module.vpc.private_subnets
  calculated_security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [module.vpc.default_security_group_id]

  calculated_public_subnets_cidrs = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k)]
  calculated_private_subnets_cidrs = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k + 6)]
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
      condition     = !(var.create_vpc == true && var.availability_zones_count == 0 && length(var.availability_zones) == 0)
      error_message = "The variable availability_zones_count must be set if availability_zones is not set"
    }

    precondition {
      condition     = !(var.create_vpc == true && var.cidr == null)
      error_message = "The variable cidr must be set if create_vpc is false. This is the cidr range used to create the VPC"
    }

    precondition {
      condition     = !(var.create_vpc == false && var.vpc_id == null)
      error_message = "The variable vpc_id must be set if create_vpc is false"
    }

    precondition {
      condition     = !(var.create_vpc == false && length(var.private_subnet_ids) == 0)
      error_message = "The variable private_subnets must be set if create_vpc is false"
    }

    precondition {
      condition     = !(var.create_vpc == false && length(var.public_subnet_ids) == 0)
      error_message = "The variable public_subnets must be set if create_vpc is false"
    }

    precondition {
      condition     = !(var.create_vpc == false && length(var.security_group_ids) == 0)
      error_message = "The variable security_group_ids must be set if create_vpc is false"
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

  name = "devzero-${terraform.workspace}-${random_string.this.result}"
  cidr = var.cidr

  azs             = local.azs
  public_subnets  = local.calculated_public_subnets_cidrs
  private_subnets = local.calculated_private_subnets_cidrs


  manage_default_network_acl = true

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
      cidr_blocks = join(",", local.calculated_private_subnets_cidrs)
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

  cluster_name = "${terraform.workspace}-${random_string.this.result}"

  region               = var.region
  environment          = var.environment
  security_group_ids   = local.calculated_security_group_ids
  subnet_ids           = local.calculated_private_subnets_ids
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

  observability_tag = null

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

  name = "${module.eks.name}-efs"

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

  security_group_ids = local.calculated_security_group_ids
  # Hack to allow terraform to know keys ahead of time
  subnet_ids = {  for i, r in local.calculated_private_subnets_ids : "mount_${i}" => r }

  depends_on = [
    module.eks,
  ]
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
