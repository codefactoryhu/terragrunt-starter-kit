module "helm-releases" {
  source  = "cloudposse/helm-release/aws"
  version = "0.10.1"

   for_each = var.helm_releases

   repository                  = each.value.repository
   chart                       = each.value.chart
   chart_version               = each.value.chart_version
   eks_cluster_oidc_issuer_url = var.eks_cluster_oidc_issuer_url

   create_namespace            = lookup(each.value, "create_namespace", false)
   kubernetes_namespace        = each.value.kubernetes_namespace

   values                      = lookup(each.value, "values", [])
   atomic                      = lookup(each.value, "atomic", true)
   cleanup_on_fail             = lookup(each.value, "cleanup_on_fail", true)

   tags                        = var.tags
}