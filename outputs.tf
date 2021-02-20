#
# Outputs
#

locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH


  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks.certificate_authority[0].data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "eks-${var.cluster-name}"
KUBECONFIG

}

# output "config_map_aws_auth" {
#   value = local.config_map_aws_auth
# }

# Commented this out as we now have `aws eks update-kubeconfig` to get the kubeconfig and its a security risk having this in the Jenkins logging.
# Uncomment this if you want it.
#output "kubeconfig" {
#  value = local.kubeconfig
#}



output "vpcid" {
  value = data.aws_vpc.vpc.id
}

output "subnetids" {
  value = data.aws_subnet_ids.private.ids
}

output "pub_subnetids" {
  value = data.aws_subnet_ids.public.ids
}


output "pubsubnet" {
  value = local.pub_sub_ids
}