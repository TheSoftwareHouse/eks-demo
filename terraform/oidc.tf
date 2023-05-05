module "aws_oidc_github" {
  source = "git@github.com:TheSoftwareHouse/terraform-modules.git//aws_oidc_github?ref=main"

  role_name    = "GithubActions"
  github_org   = "TheSoftwareHouse"
  github_repos = ["eks-demo"]
}
