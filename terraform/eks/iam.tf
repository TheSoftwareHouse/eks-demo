resource "aws_iam_policy" "external_secrets_operator" {
  name        = "external-secrets-operator-policy"
  path        = "/"
  description = "External Secrets Operator Policy"
  policy      = data.aws_iam_policy_document.external_secrets_operator.json
}
