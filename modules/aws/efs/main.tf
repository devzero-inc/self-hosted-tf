// iam
module "iam_assumable_role_admin" {
  count = var.efs_enabled ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "3.6.0"

  create_role      = true
  role_name        = "${var.name}-efs-driver"
  provider_url     = var.provider_url
  role_policy_arns = [aws_iam_policy.efs_policy.arn]

  # namespace and service account name
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:${var.efs_controller_sa_name}"]

  tags = merge(
    {
      Terraform             = "true"
      "KubespotEnvironment" = var.environment
    }, var.common_tags
  )
}

resource "aws_iam_policy" "efs_policy" {
  name        = "${var.name}-efs-policy"
  description = "EKS cluster policy for EFS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOF
}

// driver
resource "helm_release" "aws_efs_csi_driver" {
  count = var.efs_enabled ? 1 : 0

  name      = var.efs_driver_name
  namespace = "kube-system"

  repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart      = "aws-efs-csi-driver"
  depends_on = [module.iam_assumable_role_admin]

  wait = false

  values = [<<EOF
image:
  repository: 602401143452.dkr.ecr.us-east-1.amazonaws.com/eks/aws-efs-csi-driver
serviceAccount:
  controller:
    create: true
    name: ${var.efs_controller_sa_name}
    ## Enable if EKS IAM for SA is used
    annotations:
      eks.amazonaws.com/role-arn: "${module.iam_assumable_role_admin[0].this_iam_role_arn}"
EOF
  ]
}

// efs
resource "aws_efs_file_system" "efs" {
  creation_token = var.cluster_name
}

resource "aws_efs_mount_target" "efs-mount" {
  for_each = var.subnet_ids

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = each.value
  security_groups = var.security_group_ids

  depends_on = [aws_efs_file_system.efs]
}

resource "kubernetes_storage_class" "eks_sc" {
  metadata {
    name = var.efs_sc_name
  }
  storage_provisioner = "efs.csi.aws.com"
}

#resource "kubernetes_persistent_volume" "eks_pv" {
#  metadata {
#    name = var.efs_pv_name
#  }
#  spec {
#    capacity = {
#      storage = "1Gi"
#    }
#    access_modes                     = ["ReadWriteMany"]
#    storage_class_name               = var.efs_sc_name 
#    persistent_volume_reclaim_policy = "Retain"
#    persistent_volume_source {
#      csi {
#        driver        = "efs.csi.aws.com"
#        volume_handle = aws_efs_file_system.efs.id
#      }
#    }
#  }
#}

#resource "kubernetes_persistent_volume_claim" "eks-pvc" {
#  metadata {
#    name = var.efs_claim_name
#  }
#  spec {
#    resources {
#      requests = {
#        storage = "1Gi"
#      }
#    }
#    storage_class_name = var.efs_sc_name
#    access_modes       = ["ReadWriteMany"]
#  }
#}
