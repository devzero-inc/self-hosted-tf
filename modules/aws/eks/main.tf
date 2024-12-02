data "aws_iam_policy_document" "eks-cluster-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "eks-cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks-cluster-policy.json
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks-cluster.name
}

#data "aws_ami" "k8s_ubuntu_ami_1_29" {
#  name_regex  = "ubuntu-eks/k8s_1.30/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
#  most_recent = true
#  owners      = ["099720109477"]
#}
#
#resource "aws_launch_template" "ubuntu" {
#  name_prefix = "${var.cluster_name}-ubuntu"
#  image_id    = data.aws_ami.k8s_ubuntu_ami_1_29.id
#  
#  tags = merge(
#    {
#      Name = "${var.cluster_name}-launch-template"
#    },
#    var.common_tags
#  )
#
#  metadata_options {
#    http_endpoint               = "enabled"
#    http_tokens                 = "required"
#    http_put_response_hop_limit = 2
#  }
#
#  tag_specifications {
#    resource_type = "instance"
#    tags          = merge({ Name = "${var.cluster_name}-node" }, var.common_tags)
#  }
#}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster.arn
  version  = "1.30"

  vpc_config {
    security_group_ids      = var.security_group_ids
    subnet_ids              = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = merge(
    {
      Terraform = "true"
      Name      = var.cluster_name
    }, var.common_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEBSCSIDriverPolicy,
  ]
}

data "aws_iam_policy_document" "eks-node-policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "eks-node" {
  name = "${var.cluster_name}-node-iam-role"

  assume_role_policy = data.aws_iam_policy_document.eks-node-policy.json
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${aws_eks_cluster.this.name}-ng"
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = [var.worker_instance_type]

  scaling_config {
    desired_size = var.desired_node_size
    max_size     = var.max_node_size
    min_size     = var.min_node_size
  }

  tags = merge(
    {
      Terraform = "true"
      Name      = "${aws_eks_cluster.this.name}-ng"
    }, var.common_tags
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks-node-AmazonEBSCSIDriverPolicy,
  ]
}

#resource "aws_eks_node_group" "node" {
#  cluster_name    = aws_eks_cluster.this.name
#  node_group_name = "${aws_eks_cluster.this.name}-ng"
#  node_role_arn   = aws_iam_role.eks-node.arn
#  subnet_ids      = var.subnet_ids
#  instance_types  = [var.worker_instance_type]
#  ami_type        = "CUSTOM"
#
#  scaling_config {
#    desired_size = var.desired_node_size
#    max_size     = var.max_node_size
#    min_size     = var.min_node_size
#  }
#
#  launch_template {
#    id      = aws_launch_template.ubuntu.id
#    version = aws_launch_template.ubuntu.latest_version
#  }
#
#  tags = merge(
#    {
#      Terraform = "true"
#      Name      = "${aws_eks_cluster.this.name}-ng"
#    }, var.common_tags
#  )
#
#  depends_on = [
#    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
#    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
#    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
#    aws_iam_role_policy_attachment.eks-node-AmazonEBSCSIDriverPolicy,
#  ]
#}

data "aws_iam_policy_document" "ebs_csi_driver_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster.arn]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.cluster.url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.cluster.url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

  }
}

resource "aws_iam_role" "ebs_csi_driver" {
  name               = "${var.cluster_name}-ebs-csi-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonEBSCSIDriverPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

resource "aws_eks_addon" "ebs" {
  cluster_name             = aws_eks_cluster.this.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.30.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [aws_eks_node_group.node]
}

data "aws_eks_cluster" "cluster" {
  name = concat(aws_eks_cluster.this.*.id, [""])[0]
}

data "aws_eks_cluster_auth" "cluster" {
  name = concat(aws_eks_cluster.this.*.id, [""])[0]
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates.0.sha1_fingerprint]
  url             = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0]

  tags = merge(
    {
      Terraform           = "true"
      KubespotEnvironment = var.environment
    }, var.common_tags
  )
}

data "tls_certificate" "cluster" {
  url = flatten(concat(aws_eks_cluster.this[*].identity[*].oidc.0.issuer, [""]))[0]
}
