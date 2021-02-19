#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EKS Cluster
#

resource "aws_iam_role" "cluster" {
  name = "eks-${var.cluster-name}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# This no longer required after 16 Apr 2020; see this: https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
# I leave it inplace incase you need it. Just uncomment it.
#resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#  role       = aws_iam_role.cluster.name
#}

resource "aws_security_group" "cluster" {
  name        = "eks-${var.cluster-name}-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-${var.cluster-name}"
  }
}

resource "aws_eks_cluster" "eks" {
  name      = "eks-${var.cluster-name}"
  role_arn  = aws_iam_role.cluster.arn
  version   = var.k8s_version
  enabled_cluster_log_types = var.cloudwatch ? ["api", "audit", "authenticator", "controllerManager", "scheduler"] : []

  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]
    subnet_ids         = data.aws_subnet_ids.private.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
#    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
  ]
}

resource "null_resource" "tag-subnets" {
  count = length(data.aws_subnet_ids.private.ids)
  triggers = {
    version = "1"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${data.aws_subnet_ids.public.ids[count.index]} --tags Key=kubernetes.io/role/elb,Value=1 Key=kubernetes.io/cluster/${var.cluster-name},Value=shared"
  }
}
