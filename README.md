# DevOps Heavy Project — Docker + Terraform + GitHub Actions + AWS

Ek complete CI/CD pipeline demo: Node.js (Express) **Task Manager API** jo Docker mein
containerize hai, Terraform se AWS (EC2 + ECR + VPC) pr provision hoti hai, aur
GitHub Actions se automatically test → build → push → deploy hoti hai.

## Architecture

```
Developer push (main branch)
        │
        ▼
GitHub Actions CI/CD
  1. npm test (jest)
  2. docker build
  3. push image → AWS ECR
  4. AWS SSM send-command → EC2 instance pulls latest image & restarts container
        │
        ▼
   AWS EC2 (in custom VPC, public subnet)
   ├── Security Group (80 open, 22 restricted)
   ├── IAM Role (ECR ReadOnly + SSM Core, no SSH keys needed for deploy)
   └── Docker container running the app → http://<ec2-public-ip>/
```

Separately, **Terraform workflow** (`terraform.yml`) runs `plan` on every PR that touches
`terraform/**`, and `apply` automatically on merge to `main` — so infra changes go through
the same review process as code.

## Project structure

```
.
├── app/                      # Node.js Express API (Task Manager)
│   ├── src/
│   │   ├── index.js
│   │   └── routes/{health.js, tasks.js}
│   ├── test/app.test.js      # Jest + Supertest tests
│   └── package.json
├── Dockerfile                 # Multi-stage build, non-root user, healthcheck
├── docker-compose.yml         # For local dev/testing
├── terraform/                 # AWS infra as code
│   ├── main.tf, variables.tf, outputs.tf
│   ├── vpc.tf                 # VPC, subnet, IGW, route table
│   ├── security_group.tf      # Firewall rules
│   ├── ecr.tf                 # Docker image registry
│   ├── iam.tf                 # EC2 role: ECR pull + SSM access
│   └── ec2.tf                 # The instance + bootstrap user-data
└── .github/workflows/
    ├── ci-cd.yml               # test → build → push → deploy
    └── terraform.yml           # terraform fmt/validate/plan/apply
```

## 1. Local development

```bash
cd app
npm install
npm test
npm start          # runs on http://localhost:80 (needs sudo) or set PORT=3000

# OR with Docker:
docker compose up --build
# visit http://localhost:8080
```

## 2. Provision AWS infrastructure (Terraform)

Prerequisites: AWS CLI configured (`aws configure`), Terraform >= 1.5 installed.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: set ssh_allowed_cidr to your IP, region, etc.

terraform init
terraform plan
terraform apply
```

This creates: VPC + public subnet, Internet Gateway, Security Group, ECR repo,
IAM role + instance profile, and an EC2 instance that boots up, installs Docker,
and tries to pull/run the app image (first run may show no image yet — that's fine,
GitHub Actions will push the first image next).

Note the outputs: `instance_id`, `ecr_repository_url`, `app_url`.

## 3. Push the first Docker image manually (first deploy only)

```bash
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <ecr_repository_url>

docker build -t <ecr_repository_url>:latest .
docker push <ecr_repository_url>:latest
```

Then SSH or use SSM to pull it on the instance, or just wait for the next `git push`
to `main` — GitHub Actions will handle it from here on.

## 4. Set up GitHub Actions (CI/CD)

In your GitHub repo, go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user access key (with ECR + EC2/SSM permissions) |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `EC2_INSTANCE_ID` | from `terraform output instance_id` |
| `ECR_REGISTRY_URL` | from `terraform output ecr_repository_url` (registry part, e.g. `123456789.dkr.ecr.us-east-1.amazonaws.com`) |

Push to `main` → tests run → image builds & pushes to ECR → SSM command redeploys
the container on EC2 automatically. Zero SSH keys needed for deployment.

## 5. Terraform changes via PR

Any change under `terraform/` opens a PR → `terraform.yml` runs `plan` and posts the
diff as a check. Merging to `main` runs `apply` automatically.

## Notes / production hardening ideas

- Move Terraform state to S3 + DynamoDB lock (commented block in `main.tf`).
- Restrict `ssh_allowed_cidr` to your own IP, or remove SSH entirely and rely only on SSM.
- Add an Application Load Balancer + Auto Scaling Group instead of a single EC2 instance.
- Add RDS for a real database instead of the in-memory task store.
- Add CloudWatch alarms/logs.
