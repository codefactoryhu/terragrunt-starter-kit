provider "kubernetes" {
  host                   = aws_eks_cluster.this[0].endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this[0].certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.default.token
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.this[0].id]
  }
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}