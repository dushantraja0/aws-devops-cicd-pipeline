Yahan aapka complete, professional, aur clean `README.md` document hai. Aap ise seedha apni repository mein replace kar sakte hain:

```markdown
# AWS DevOps CI/CD Pipeline

[![CI/CD Pipeline](https://github.com/dushantraja0/aws-devops-cicd-pipeline/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/dushantraja0/aws-devops-cicd-pipeline/actions)
[![Terraform Automation](https://github.com/dushantraja0/aws-devops-cicd-pipeline/actions/workflows/terraform.yml/badge.svg)](https://github.com/dushantraja0/aws-devops-cicd-pipeline/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-ready DevOps demonstration deploying a containerized **Node.js (Express) Task Manager API** to **AWS Infrastructure (EC2, ECR, custom VPC)** using **Terraform** for Infrastructure as Code (IaC) and **GitHub Actions** for automated CI/CD.

---

## 📌 Architecture Overview


```

```
                      [ Developer Push / Merge ]
                                 │
                                 ▼
                      ┌─────────────────────┐
                      │  GitHub Actions     │
                      └──────────┬──────────┘
                                 │
         ┌───────────────────────┴───────────────────────┐
         ▼                                               ▼

```

[ Application Pipeline ]                        [ Terraform Pipeline ]

1. Run Unit Tests (Jest)                        1. Format & Validate
2. Build Docker Image                           2. Plan Infrastructure
3. Push Image to AWS ECR                        3. Apply Infrastructure
4. Trigger AWS SSM Command                              │
│                                             ▼
▼                                    ┌──────────────────┐
┌──────────────────┐                           │ Provision AWS    │
│   AWS ECR Repo   │                           │ Infrastructure   │
└─────────┬────────┘                           └──────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────────┐
│ AWS Custom VPC (Public Subnet)                                  │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │ AWS EC2 Instance                                        │   │
│   │  ├── Security Group (Port 80 HTTP, Restricted SSH)       │   │
│   │  ├── IAM Role (ECR Read-Only + SSM Managed Instance)    │   │
│   │  └── Docker Container (Node.js API)                      │   │
│   └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
│
▼
http://<EC2_PUBLIC_IP>/

```

### Key Highlights
- **Zero-SSH Deployment:** Deployment on EC2 is executed safely via **AWS Systems Manager (SSM) Run Command**, eliminating the need to store SSH keys inside GitHub Secrets.
- **GitOps Infrastructure Management:** Infrastructure updates under `terraform/` are validated via PR checks (`terraform plan`) and automatically applied upon merging to `main`.
- **Security-First Approach:** Implements IAM least-privilege roles, isolated network subnets, and multi-stage non-root Docker execution.

---

## 📁 Repository Structure

```text
.
├── .github/workflows/
│   ├── ci-cd.yml             # Application CI/CD (Test -> Build -> Push -> Deploy)
│   └── terraform.yml         # Infrastructure CI/CD (Fmt -> Plan -> Apply)
├── app/                      # Node.js Express REST API
│   ├── src/                  # Application source code
│   ├── test/                 # Jest & Supertest automated test suite
│   └── package.json
├── terraform/                # Infrastructure as Code
│   ├── main.tf               # Terraform provider configuration
│   ├── vpc.tf                # VPC, Subnet, Internet Gateway, & Route Tables
│   ├── security_group.tf     # Network firewall policies
│   ├── ecr.tf                # AWS Elastic Container Registry definition
│   ├── iam.tf                # EC2 IAM instance profiles (SSM & ECR policies)
│   ├── ec2.tf                # Compute instance & user-data bootstrap logic
│   ├── variables.tf          # Input variable definitions
│   └── outputs.tf            # Provisioning deployment outputs
├── Dockerfile                # Production multi-stage Docker build
├── docker-compose.yml        # Local development environment setup
└── README.md

```

---

## 🛠️ Tech Stack & Prerequisites

* **Cloud Provider:** AWS (EC2, ECR, VPC, IAM, SSM)
* **IaC Engine:** Terraform >= 1.5
* **Containers:** Docker, Docker Compose
* **CI/CD Platform:** GitHub Actions
* **Application Framework:** Node.js (Express.js), Jest

### Prerequisites

Before running or deploying this repository, ensure you have:

1. An active **AWS Account** with sufficient IAM permissions.
2. **AWS CLI v2** installed and configured (`aws configure`).
3. **Terraform CLI** and **Docker Engine** installed locally.

---

## 🚀 Quick Start & Deployment Guide

### 1. Local Development

Run the API locally using standard Node.js or Docker Compose:

```bash
# Using Docker Compose (Recommended)
docker compose up --build

# Test local endpoint
curl http://localhost:8080/health

```

Alternatively, run without Docker:

```bash
cd app
npm install
npm test
npm start

```

---

### 2. Infrastructure Provisioning (Terraform)

Initialize and deploy the base AWS infrastructure:

```bash
cd terraform

# Setup local variable file
cp terraform.tfvars.example terraform.tfvars

# Review and edit terraform.tfvars as needed
# e.g., ssh_allowed_cidr = "YOUR_LOCAL_IP/32"

# Provision resources
terraform init
terraform plan
terraform apply -auto-approve

```

> **Note:** Take note of the Terraform output values: `instance_id`, `ecr_repository_url`, and `app_url`.

---

### 3. CI/CD Configuration (GitHub Secrets)

To enable automated pipelines, navigate to your GitHub Repository **Settings → Secrets and variables → Actions** and add the following secret keys:

| Secret Name | Description | Example Value |
| --- | --- | --- |
| `AWS_ACCESS_KEY_ID` | IAM User Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | IAM User Secret Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | Target AWS Region | `us-east-1` |
| `EC2_INSTANCE_ID` | Target EC2 Instance ID | `i-0123456789abcdef0` |
| `ECR_REGISTRY_URL` | ECR Registry Base Domain | `123456789012.dkr.ecr.us-east-1.amazonaws.com` |

---

### 4. Continuous Integration & Deployment Workflow

Once configured, the workflow executes automatically on repository events:

1. **Application Pipeline (`ci-cd.yml`):**
* Triggers on `push` to `main` (when code in `app/`, `Dockerfile`, or workflows change).
* Runs `npm test` inside the app directory.
* Builds the Docker container and pushes it to **AWS ECR** tagged with the git commit SHA and `latest`.
* Sends an **AWS SSM** command to the target EC2 instance to execute a zero-downtime pull and container reload.


2. **Terraform Pipeline (`terraform.yml`):**
* Triggers on Pull Requests touching `terraform/**` to execute `terraform plan` and comment the diff.
* Automatically runs `terraform apply` upon merging the Pull Request to `main`.



---

## 🛡️ Production Hardening Recommendations

* **Remote State Storage:** Migrate Terraform state from local files to an **S3 Bucket** with state locking enabled via **DynamoDB**.
* **High Availability:** Replace single EC2 instance execution with an **Application Load Balancer (ALB)** and **Auto Scaling Group (ASG)** across multiple Availability Zones.
* **Data Persistence:** Integrate an **AWS RDS (PostgreSQL/MySQL)** instance instead of the transient in-memory store.
* **Monitoring & Logging:** Enable **AWS CloudWatch Agent** on the instance to stream application logs and set up high-memory/CPU alarms.

---

## 📜 License

This project is licensed under the [MIT License](https://www.google.com/search?q=LICENSE).

```

```
