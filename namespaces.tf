# resource "kubernetes_namespace" "prometheus-ns" {
#   metadata {
#     name = "monitoring"
#   }
# }

resource "kubernetes_namespace" "ingress-nginx-ns" {
  count       = var.helm_ingress ? 1 : 0
  metadata {
    name = "ingress-nginx"
  }
}
