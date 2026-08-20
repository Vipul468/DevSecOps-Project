# DevOps Project-2 — Amazon Prime Clone (Fully Automated CI/CD)

End-to-end DevOps pipeline that builds an Amazon Prime clone (React), runs it
through security + quality gates, and deploys it to **AWS EKS** via **GitOps**.

```
GitHub ─▶ Jenkins ─▶ SonarQube ─▶ npm build ─▶ Trivy ─▶ Docker ─▶ AWS ECR
                                                                     │
Terraform provisions:  EKS · ECR · VPC · IAM                        ▼
Argo CD (GitOps) ─▶ AWS EKS ─▶ Pod  ◀── pulls image ── AWS ECR
Monitoring: Helm ─▶ Prometheus + Grafana  (watch the EKS cluster)
```

## Repo layout

```
devops-project2/
├── app/                 # Dockerfile + nginx.conf for the React clone (clone app source here)
├── terraform/           # AWS infra: VPC, EKS, ECR, IAM  (terraform apply)
├── jenkins/  scripts/   # setup scripts for Jenkins node + toolchain + SonarQube
├── kubernetes/          # Deployment + Service + Namespace (Argo CD watches this)
├── argocd/              # Argo CD Application (GitOps)
├── monitoring/          # kube-prometheus-stack Helm values
├── Jenkinsfile          # the CI/CD pipeline
├── sonar-project.properties
└── docs/                # full step-by-step execution guide (PDF)
```

## Quick start (high level)

1. Launch an Ubuntu EC2 (t2.large+), run `scripts/install-tools.sh` then `scripts/install-jenkins.sh`.
2. `cd terraform && terraform init && terraform apply` → creates EKS + ECR.
3. `aws eks update-kubeconfig ...` (printed by terraform output).
4. Install Argo CD + kube-prometheus-stack (Helm).
5. In Jenkins: add credentials, create a Pipeline job pointing at this repo, **Build**.
6. Argo CD auto-syncs the new image to EKS. Grafana shows the metrics.

👉 **Full copy-paste commands are in `docs/EXECUTION-GUIDE.pdf`.**

> ⚠️ This spins up real AWS resources (EKS + NAT + ELB) that cost money.
> Run `terraform destroy` when you're done.
