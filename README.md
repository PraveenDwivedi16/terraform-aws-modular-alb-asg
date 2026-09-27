# 🚀 Production-Grade Modular AWS Architecture: Multi-AZ Auto Scaling Group (ASG) behind Application Load Balancer (ALB)

An enterprise-ready, highly available, and fault-tolerant cloud infrastructure deployed on **Amazon Web Services (AWS)** using **Reusable Terraform Modules**.

Designed following the **AWS Well-Architected Framework** for reliability, security (least-privilege perimeter chaining), and cost optimization across multiple environments (`dev` & `prod`).

---

## 🏛️ Architecture Overview

```text
                                     INTERNET
                                        │
                                        ▼ [Port 80 HTTP]
                         ┌─────────────────────────────┐
                         │  AWS Application Load       │ (Public Subnets across AZ-a & AZ-b)
                         │  Balancer (ALB)             │
                         └──────────────┬──────────────┘
                                        │
                 ┌──────────────────────┴──────────────────────┐
                 │ Target Group Health Checks (Port 80)        │
                 ▼                                             ▼
    ┌──────────────────────────┐                  ┌──────────────────────────┐
    │ Availability Zone 1      │                  │ Availability Zone 2      │
    │ ┌──────────────────────┐ │                  │ ┌──────────────────────┐ │
    │ │ EC2 Web Instance 1   │ │                  │ │ EC2 Web Instance 2   │ │
    │ │ (Nginx + IMDSv2)     │ │                  │ │ (Nginx + IMDSv2)     │ │
    │ └──────────────────────┘ │                  │ └──────────────────────┘ │
    └──────────────────────────┘                  └──────────────────────────┘
                 ▲                                             ▲
                 └──────────────────────┬──────────────────────┘
                                        │
                         ┌──────────────┴──────────────┐
                         │  AWS Auto Scaling Group     │
                         │  (Scale Out/In on CPU > 70%)│
                         └─────────────────────────────┘
```

---

## 🔑 Key Engineering Highlights

### 1. 🧩 100% Reusable Custom Terraform Modules
* **`modules/vpc`**: Multi-AZ VPC provisioning with public and private subnets, Internet Gateway, and custom route tables.
* **`modules/security_groups`**: Security Group chaining. The EC2 instances **only** accept HTTP traffic from the ALB security group, blocking direct external access.
* **`modules/alb`**: Internet-facing Application Load Balancer with HTTP listeners, target groups, and intelligent health checking.
* **`modules/asg`**: EC2 Launch Template with IMDSv2 metadata security, automated Nginx bootstrapping, dynamic HTML rendering, rolling update strategy (`instance_refresh`), and target-tracking CPU auto-scaling policies.

### 2. 🌍 Multi-Environment Separation (`dev` vs `prod`)
* Independent environment directories with their own `terraform.tfvars`, state, and scaling capacities:
  * **`dev`**: Lightweight sizing (`t2.micro`, 1-3 instances) for cost efficiency.
  * **`prod`**: Production sizing (`t3.small`, 2-6 instances) for high concurrency and resilience.

### 3. 🛡️ Security & CIS Benchmark Compliance
* **IMDSv2 Enforced**: EC2 instances require session tokens for metadata queries, mitigating SSRF credential theft.
* **Least-Privilege Firewalls**: EC2 security groups do not expose port 80 to `0.0.0.0/0`.
* **Zero Hardcoded Secrets**: Fully parameterized inputs via standard Terraform variables.

---

## 📁 Repository Structure

```text
├── modules/
│   ├── vpc/                 # Multi-AZ VPC, Subnets, IGW, Route Tables
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security_groups/     # ALB & ASG Security Groups with chaining
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/                 # ALB, Target Group, Listeners & Health Checks
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── asg/                 # Launch Template, Auto Scaling Group, CPU Scaling Policy
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── user_data.sh     # Nginx bootstrap with dynamic metadata
├── environments/
│   ├── dev/                 # Dev environment instantiation
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── prod/                # Production environment instantiation
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       └── versions.tf
├── .gitignore
└── README.md
```

---

## 🚀 Quickstart Guide

### 1. Prerequisites
* [Terraform v1.5+](https://developer.hashicorp.com/terraform/install)
* AWS CLI configured with active credentials (`aws configure`)

### 2. Deployment Steps

```bash
# Clone the repository
git clone https://github.com/PraveenDwivedi16/terraform-aws-modular-alb-asg.git
cd terraform-aws-modular-alb-asg/environments/dev

# Initialize Terraform & download AWS provider
terraform init

# Validate configuration syntax
terraform validate

# Review the execution plan
terraform plan

# Deploy infrastructure
terraform apply -auto-approve
```

### 3. Verification
Once applied, Terraform outputs the public ALB URL:
```text
Outputs:
alb_public_url = "http://cloud-scale-dev-alb-xxxx.us-east-1.elb.amazonaws.com"
```
Open the URL in any browser. Refreshing the page demonstrates traffic automatically cycling across different EC2 instances and Availability Zones!

### 4. Teardown (Prevent Cloud Billing)
```bash
terraform destroy -auto-approve
```

---

## 👨‍💻 Author
**Praveen Dwivedi**  
*Senior DevOps & SRE Engineer | RHCSA | AWS Certified Solutions Architect*  
LinkedIn: [praveen-dwivedi-devops](https://www.linkedin.com/in/praveen-dwivedi-devops/)
