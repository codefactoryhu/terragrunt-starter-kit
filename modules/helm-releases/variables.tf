variable "helm_releases" {
    type = any
}

variable "eks_cluster_oidc_issuer_url" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "tags" {
  type = any
}