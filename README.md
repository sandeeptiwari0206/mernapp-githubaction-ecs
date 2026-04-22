<div align="center">

# 🐳 MERN App — CI/CD with GitHub Actions + AWS ECS

### Full-stack MERN application containerised with Docker, images pushed to ECR, and deployed to AWS ECS via GitHub Actions

[![MongoDB](https://img.shields.io/badge/MongoDB-Database-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)
[![Express](https://img.shields.io/badge/Express.js-Backend-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com/)
[![React](https://img.shields.io/badge/React-Frontend-61DAFB?style=for-the-badge&logo=react&logoColor=black)](https://reactjs.org/)
[![Node.js](https://img.shields.io/badge/Node.js-Runtime-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![AWS ECS](https://img.shields.io/badge/AWS-ECS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/ecs/)
[![AWS ECR](https://img.shields.io/badge/AWS-ECR-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/ecr/)
[![Docker](https://img.shields.io/badge/Docker-Containerized-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)

<br/>

> *Every push to `main` builds Docker images, pushes to AWS ECR, and triggers an ECS service update — fully serverless container deployment with zero SSH.*

</div>

---

## 📌 Table of Contents

- [Overview](#-overview)
- [EC2 vs ECS — Key Difference](#-ec2-vs-ecs--key-difference)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [CI/CD Pipeline](#-cicd-pipeline)
- [AWS Setup](#-aws-setup)
- [Getting Started](#-getting-started)
- [GitHub Secrets Setup](#-github-secrets-setup)
- [Local Development](#-local-development)
- [Author](#-author)

---

## 📖 Overview

This project deploys a **MERN stack application to AWS ECS (Elastic Container Service)** using a fully automated GitHub Actions pipeline — no servers to SSH into, no manual `docker compose` commands.

Every commit to `main`:
1. Builds **separate Docker images** for frontend and backend
2. Pushes images to **AWS ECR** (Elastic Container Registry) tagged with the Git SHA
3. Updates the **ECS Task Definition** with the new image URI
4. Triggers an **ECS Service update** — ECS pulls the new images and performs a rolling deployment automatically

---

## ⚖️ EC2 vs ECS — Key Difference

| Feature | EC2 Deployment | ECS Deployment (this repo) |
|---------|---------------|---------------------------|
| **Server management** | You manage the EC2 instance | AWS manages the infrastructure |
| **Deployment method** | SSH + docker compose | ECS rolling update |
| **Image registry** | Docker Hub | AWS ECR (private) |
| **Scaling** | Manual / ASG setup | ECS auto-scaling built-in |
| **Zero-downtime** | Manual blue/green | ECS rolling update native |
| **Best for** | Simple, full control | Production-grade, managed |

---

## 🏗 Architecture

```
Developer
    │
    │  git push main
    ▼
┌──────────────────────────────────────────────────────────────────┐
│                       GitHub Actions                              │
│                                                                  │
│  ┌──────────────┐  ┌─────────────────┐  ┌─────────────────────┐ │
│  │  Checkout    │─►│  Build Docker   │─►│  Update ECS Task    │ │
│  │  Code        │  │  Images & Push  │  │  Definition &       │ │
│  └──────────────┘  │  to AWS ECR     │  │  Deploy Service     │ │
│                    └─────────────────┘  └─────────────────────┘ │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
               ┌──────────────────────────┐
               │        AWS ECR            │
               │  <account>.dkr.ecr./      │
               │  mern-frontend:sha        │
               │  mern-backend:sha         │
               └──────────────┬────────────┘
                              │  image pull
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│                        AWS ECS Cluster                            │
│                                                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   ECS Service                              │  │
│  │                                                           │  │
│  │  ┌──────────────────────────┐                             │  │
│  │  │       ECS Task            │  ← Task Definition (JSON)  │  │
│  │  │                          │                             │  │
│  │  │  ┌──────────┐  ┌───────┐ │                             │  │
│  │  │  │ Frontend │  │Backend│ │                             │  │
│  │  │  │ :80      │◄─│ :5000 │ │                             │  │
│  │  │  └──────────┘  └───┬───┘ │                             │  │
│  │  └────────────────────┼─────┘                             │  │
│  └───────────────────────┼───────────────────────────────────┘  │
│                          │                                       │
│             ┌────────────▼──────────┐                           │
│             │  Application Load      │                           │
│             │  Balancer (ALB)        │                           │
│             │  Port 80 / 443         │                           │
│             └───────────────────────┘                           │
└──────────────────────────────────────────────────────────────────┘
                          │
              ┌───────────▼───────────┐
              │   MongoDB Atlas        │
              │   (Cloud Database)     │
              └───────────────────────┘
```

---

## 📁 Project Structure

```
mernapp-githubaction-ecs/
│
├── .github/
│   └── workflows/
│       └── deploy.yml             # GitHub Actions CI/CD pipeline
│
├── frontend/                      # React application
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── App.js
│   ├── public/
│   ├── Dockerfile                 # Multi-stage: build → Nginx serve
│   ├── nginx.conf                 # Nginx reverse proxy to backend
│   └── package.json
│
├── backend/                       # Node.js + Express REST API
│   ├── src/
│   │   ├── routes/
│   │   ├── models/                # Mongoose schemas
│   │   ├── controllers/
│   │   └── server.js
│   ├── Dockerfile
│   └── package.json
│
├── task-definition.json           # ECS Task Definition template
├── docker-compose.yml             # Local development only
└── .gitignore
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|-----------|
| **Frontend** | React.js, Nginx |
| **Backend** | Node.js, Express.js |
| **Database** | MongoDB Atlas (cloud) |
| **Containerisation** | Docker |
| **CI/CD** | GitHub Actions |
| **Container Registry** | AWS ECR (Elastic Container Registry) |
| **Orchestration** | AWS ECS (Elastic Container Service) |
| **Load Balancer** | AWS ALB (Application Load Balancer) |
| **IAM** | AWS IAM roles for ECS task execution |

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/deploy.yml`) runs on every push to `main`:

```
git push main
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│  Step 1: Configure AWS Credentials                            │
│  • aws-actions/configure-aws-credentials@v2                  │
│  • Uses: AWS_ACCESS_KEY_ID + AWS_SECRET_ACCESS_KEY           │
└──────────────────────────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│  Step 2: Login to Amazon ECR                                  │
│  • aws-actions/amazon-ecr-login@v1                           │
│  • Authenticates Docker to your private ECR registry         │
└──────────────────────────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│  Step 3: Build & Push Docker Images to ECR                    │
│  • docker build frontend  → ECR_URI/mern-frontend:sha        │
│  • docker build backend   → ECR_URI/mern-backend:sha         │
│  • docker push both images                                   │
└──────────────────────────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│  Step 4: Update ECS Task Definition                           │
│  • aws-actions/amazon-ecs-render-task-definition@v1          │
│  • Injects new image URI into task-definition.json           │
└──────────────────────────────────────────────────────────────┘
      │
      ▼
┌──────────────────────────────────────────────────────────────┐
│  Step 5: Deploy to ECS Service                                │
│  • aws-actions/amazon-ecs-deploy-task-definition@v1          │
│  • Registers new task definition revision                    │
│  • Triggers rolling update on ECS service                    │
│  • wait-for-service-stability: true                          │
└──────────────────────────────────────────────────────────────┘
```

### Sample Workflow YAML Structure

```yaml
name: MERN App — Build & Deploy to ECS

on:
  push:
    branches: [main]

env:
  AWS_REGION: ap-south-1
  ECR_FRONTEND: mern-frontend
  ECR_BACKEND: mern-backend
  ECS_CLUSTER: mern-cluster
  ECS_SERVICE: mern-service

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build & Push Images to ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_BACKEND:$IMAGE_TAG ./backend
          docker build -t $ECR_REGISTRY/$ECR_FRONTEND:$IMAGE_TAG ./frontend
          docker push $ECR_REGISTRY/$ECR_BACKEND:$IMAGE_TAG
          docker push $ECR_REGISTRY/$ECR_FRONTEND:$IMAGE_TAG

      - name: Update ECS Task Definition & Deploy
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: task-definition.json
          service: ${{ env.ECS_SERVICE }}
          cluster: ${{ env.ECS_CLUSTER }}
          wait-for-service-stability: true
```

---

## ☁️ AWS Setup

Before running the pipeline, ensure the following AWS resources exist:

### 1. ECR Repositories

```bash
# Create ECR repos
aws ecr create-repository --repository-name mern-frontend --region ap-south-1
aws ecr create-repository --repository-name mern-backend  --region ap-south-1
```

### 2. ECS Cluster

```bash
aws ecs create-cluster --cluster-name mern-cluster
```

### 3. ECS Task Definition (`task-definition.json`)

```json
{
  "family": "mern-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::<account-id>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "mern-backend",
      "image": "<account-id>.dkr.ecr.ap-south-1.amazonaws.com/mern-backend:latest",
      "portMappings": [{ "containerPort": 5000 }],
      "environment": [
        { "name": "MONGO_URI", "value": "your_atlas_uri" }
      ]
    },
    {
      "name": "mern-frontend",
      "image": "<account-id>.dkr.ecr.ap-south-1.amazonaws.com/mern-frontend:latest",
      "portMappings": [{ "containerPort": 80 }]
    }
  ]
}
```

### 4. ECS Service

```bash
aws ecs create-service \
  --cluster mern-cluster \
  --service-name mern-service \
  --task-definition mern-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
```

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/sandeeptiwari0206/mernapp-githubaction-ecs.git
cd mernapp-githubaction-ecs
```

### 2. Set Up AWS Infrastructure

Follow the [AWS Setup](#-aws-setup) section above to create ECR repos, ECS cluster, and service.

### 3. Configure GitHub Secrets

Add all required secrets (see below), then push to `main` to trigger the pipeline.

---

## 🔐 GitHub Secrets Setup

Go to: **Repo → Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | IAM user access key with ECS + ECR permissions |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key |
| `AWS_REGION` | e.g. `ap-south-1` |
| `ECR_REGISTRY` | `<account-id>.dkr.ecr.<region>.amazonaws.com` |
| `MONGO_URI` | MongoDB Atlas connection string |

### Required IAM Permissions

```json
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:InitiateLayerUpload",
    "ecr:PutImage",
    "ecs:RegisterTaskDefinition",
    "ecs:UpdateService",
    "ecs:DescribeServices",
    "iam:PassRole"
  ],
  "Resource": "*"
}
```

---

## 💻 Local Development

```bash
# Create .env
echo "MONGO_URI=your_mongodb_atlas_uri" > .env
echo "IMAGE_TAG=local" >> .env

# Start all services locally
docker compose up --build

# Frontend: http://localhost:80
# Backend:  http://localhost:5000
```

---

## 👨‍💻 Author

<div align="center">

**Sandeep Tiwari** — Cloud Engineer & DevOps Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/sandeep-tiwari-616a33116/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/sandeeptiwari0206)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit-3b82f6?style=flat-square)](https://your-portfolio-url.com)

📍 Jaipur, Rajasthan, India

</div>

---

<div align="center">

⭐ **If this project helped you, give it a star!**

</div>
