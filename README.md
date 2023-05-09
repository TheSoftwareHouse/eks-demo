# Access

To access cluster, assume role from TSH-Devops-Sandbox (AdministratorAccess), same for working with Terraform (there are differences when applying through Github Actions, because caller identity is different, best to leave Terraform to by handled by Github Actions)

# Bootstrap

Getting Access To Cluster
```
aws eks update-kubeconfig --region eu-west-1 --name eks-demo-tsh
```
Install ArgoCD
```
task argocd:install
```

**BEFORE YOU PROCEED, SET UP PROPER VALUES FOR ALL APPLICATIONS/CHARTS (E.G. IRSA ROLES/VPC NAMES ETC)**

Bootstrap Cluster
```
kubectl apply -f argo/clusters/eks-demo-tsh/bootstrap/bootstrap.yaml
```

# Ingress Hosts

ArgoCD is already exposed (wildcard certificate created by AWS Organisation Terragrunt) [here](https://argocd.devops-sandbox.aws.tsh.io/). Username is `admin` and to get password use command:
```
kubectl get secret --namespace argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

# Next Steps

Set up any extra tools left

- Karpenter (OCI Chart Repository - how to handle OCI with Argo?)
- External Secret Operator
- Monitoring Stack
- Datadog Integration for Demo? 

And set up simple application for Demo purposes

- add `applications/` directory
- create simple `FROM: nginx ADD index.html` Dockerfile
- add ECR repository in Terraform
- make pipeline to build & push Docker image
- as last step, you either set up ArgoCD Image Updater or add step to pipeline to update image in Application maniffest for ArgoCD
```
# example from GitLab
  variables:
    IMAGE_TAG_PATH: .spec.values.image.tag
  script:
    - 'git clone -b master https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/example/flux-aws.git'
    - COMMIT=$CI_COMMIT_REF_NAME-$CI_COMMIT_SHA yq e "${IMAGE_TAG_PATH} = strenv(COMMIT)" -i "flux-aws/$ENVIRONMENT/$CLUSTER/helmreleases/internal/$RELEASE_NAME.yaml"
```

# ArgoCD CLI

Login:
```
argocd login argocd.devops-sandbox.aws.tsh.io
User: admin
Password:
```

Add Public OCI Repository:
```
argocd repo add public.ecr.aws/karpenter/karpenter --type helm --name karpenter --enable-oci
```
