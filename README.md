# Full-Stack CI/CD Pipeline on AWS

Simple app with two buttons that hit different API endpoints. The real project here is the automated deployment pipeline and cloud infrastructure.

## Tools Used

- **Terraform** – Infrastructure as Code for provisioning all AWS resources (VPC, ALB, ECS, ECR, SQS, S3, CloudFront, IAM, CloudWatch).
- **AWS** – Cloud provider hosting the production environment.
- **Docker** – Containerization of client, server, and consumer services.
- **GitHub Actions** – CI/CD pipelines for testing, validation, and deployment.
- **Kubernetes (Minikube)** – Used in CI only for smoke and end-to-end testing.
- **React** – Frontend application built as static files and deployed to S3.
- **Node.js** – Backend API and background consumer runtime.
- **SonarCloud** – Static code analysis during CI.
- **Gitleaks** – Secret scanning on Pull Requests.

## Architecture

Three main pieces:

- **Client** - React app on S3/CloudFront
- **Server** - Node API on ECS Fargate behind a load balancer
- **Consumer** - Worker processing SQS messages

## Workflow

Using trunk-based development:

```bash
git checkout main
git pull
git checkout -b feature/my-branch
git add .
git commit -m "Add feature"
git push -u origin feature/my-branch
```

Open a PR and the CI starts.

## CI Pipeline

Runs on every PR with four jobs:

**Unit Tests** - Runs Jest tests for client and server

**Secret Scan** - Gitleaks checks the full git history for leaked credentials

**SonarCloud** - Static code analysis (only runs if tests pass)

**Minikube Smoke Test** - Spins up local k8s, builds images, deploys everything, runs e2e tests. Dumps logs if it fails.

All must pass to merge.

## CD Pipeline

Triggers automatically when PR merges to main:

1. **Build** - Creates Docker images, tags with commit SHA + latest
2. **Test** - Quick sanity checks on images
3. **Push** - Uploads to ECR
4. **Deploy** - Syncs React build to S3, forces ECS service redeployment
5. **Verify** - Health checks on endpoints after 60s

If health checks fail, deployment fails.

## Infrastructure (Terraform)

Everything's modular:

- **VPC** with public/private subnets
- **ECS** cluster running Fargate containers
- **ALB** routing traffic to server
- **SQS** for async processing
- **ECR** with image scanning
- **CloudWatch** for logs
- **IAM** roles for SQS access

The consumer and server both have permissions to read/write the queue.

## Local Testing

Kubernetes manifests let you run the whole stack locally with Minikube before pushing to AWS.
