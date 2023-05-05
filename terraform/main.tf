resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"

  name                   = "eks.demo.aws.tsh.io"
  cidr                   = "172.40.0.0/16"
  enable_dns_hostnames   = true
  enable_dns_support     = true
  single_nat_gateway     = true
  enable_nat_gateway     = true
  one_nat_gateway_per_az = false

  vpc_tags = {
    Description = "EKS VPC"
  }

  azs = ["eu-west-1a", "eu-west-1b"]

  public_subnet_names = ["public.eks.demo.aws.tsh.io"]
  public_subnets = [
    "172.40.0.0/22",
    "172.40.4.0/22"
  ]
  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/eks-demo-aws-tsh-io" = "owned"
  }

  private_subnet_names = [
    "private.eks.demo.aws.tsh.io"
  ]
  private_subnets = [
    "172.40.32.0/19",
    "172.40.64.0/19",
    "172.40.96.0/19",
    "172.40.128.0/19"
  ]

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/eks-demo-aws-tsh-io" = "owned"
    "karpenter.sh/discovery"                    = "eks-demo-aws-tsh-io"
  }

  database_subnet_names = [
    "database.eks.demo.aws.tsh.io"
  ]
  database_subnets = [
    "172.40.160.0/24",
    "172.40.161.0/24",
    "172.40.162.0/24",
    "172.40.163.0/24"
  ]

  database_subnet_tags = {}

  tags = {}
}

module "eks" {
  source = "github.com/TheSoftwareHouse/aws-eks-cluster.git?ref=main"

  cluster_name    = "eks-demo-tsh"
  cluster_version = "1.26"

  # temporary workaround for cidr range
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  # cluster_endpoint_public_access_cidrs = concat([
  #   "87.206.27.228/32"
  # ], data.github_ip_ranges.this.actions_ipv4)
  #
  vpc_id      = module.vpc.vpc_id
  vpc_subnets = module.vpc.private_subnets

  # eks addons
  enable_coredns                      = true
  enable_kube_proxy                   = true
  enable_vpc_cni                      = true
  enable_aws_ebs_csi_driver           = true
  enable_aws_load_balancer_controller = true
  enable_external_dns                 = true

  # irsa roles
  create_aws_ebs_csi_driver_irsa_role           = true
  create_aws_load_balancer_controller_irsa_role = true
  create_external_dns_irsa_role                 = true
  additional_irsa_roles = [
    {
      name      = "external-secrets"
      namespace = "external-secrets"
      role_policy_arns = {
        external-secrets-operator-policy = aws_iam_policy.external_secrets_operator.arn
      }
    },
  ]

  enable_karpenter                 = true
  create_karpenter_service_account = true

  kms_key_administrators = [
    "arn:aws:iam::005699609604:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_AdministratorAccess_a30cfa46d3f823dc",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
    data.aws_caller_identity.current.arn
  ]

  aws_auth_roles = [
    # tsh-devops-sandbox
    {
      rolearn  = "arn:aws:iam::005699609604:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_AdministratorAccess_a30cfa46d3f823dc"
      username = "AWSAdministratorAccess:{{SessionName}}"
      groups   = ["system:masters"]
    }
  ]

  tags = {}
}
