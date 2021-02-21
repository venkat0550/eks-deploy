resource "helm_release" "nginx_ingress" {
  count       = var.helm_ingress ? 1 : 0
  name       = "nginx-ingress-controller"
  depends_on = [aws_eks_cluster.eks, kubernetes_namespace.ingress-nginx-ns]

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}