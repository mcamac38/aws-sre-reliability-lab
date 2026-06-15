data "aws_ami" "packer_eks_node" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "tag:Project"
    values = ["sre-lab"]
  }

  filter {
    name   = "tag:BuiltBy"
    values = ["Packer"]
  }

  filter {
    name   = "tag:Purpose"
    values = ["EKS worker node AMI"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_iam_role" "eks_node_group" {
  name = "${local.name_prefix}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-node-group-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_readonly" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_ssm_managed_instance_core" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${local.name_prefix}-nodes-"
  image_id      = data.aws_ami.packer_eks_node.id
  instance_type = "t3.medium"

  user_data = base64encode(templatefile("${path.module}/node-user-data.tpl", {
    cluster_name         = aws_eks_cluster.main.name
    cluster_endpoint     = aws_eks_cluster.main.endpoint
    cluster_ca           = aws_eks_cluster.main.certificate_authority[0].data
    cluster_service_cidr = aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr
    cluster_dns          = cidrhost(aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr, 10)
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name      = "${local.name_prefix}-eks-node"
      Component = "eks-node"
      AMISource = "Packer"
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags, {
      Name      = "${local.name_prefix}-eks-node-volume"
      Component = "eks-node"
      AMISource = "Packer"
    })
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-node-launch-template"
    Component = "eks-node"
    AMISource = "Packer"
  })
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${local.name_prefix}-nodes"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids      = aws_subnet.private[*].id

  capacity_type = "ON_DEMAND"

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  labels = {
    workload   = "general"
    ami_source = "packer"
  }

  tags = merge(local.common_tags, {
    Name      = "${local.name_prefix}-nodes"
    Component = "eks-node-group"
    AMISource = "Packer"
  })

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_readonly,
    aws_iam_role_policy_attachment.eks_ssm_managed_instance_core
  ]
}