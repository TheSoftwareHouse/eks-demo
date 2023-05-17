data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "external_secrets_operator" {
  statement {
    sid    = "ExternalSecretReadAccess"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]

    resources = ["arn:aws:secretsmanager:eu-west-1:${data.aws_caller_identity.current.account_id}:secret:eks/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/eks/kind"
      values   = ["ExternalSecret"]
    }

    condition {
      test     = "Null"
      variable = "aws:ResourceTag/eks/namespace"
      values   = ["false"]
    }
  }
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name

  depends_on = [
    module.eks
  ]
}
