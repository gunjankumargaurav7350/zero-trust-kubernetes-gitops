# 🛡️ Zero-Trust Kubernetes GitOps: Enterprise Production Platform

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30+-326CE5.svg?logo=kubernetes)](https://kubernetes.io/)
[![Cilium](https://img.shields.io/badge/Network-Cilium_eBPF-F38020.svg?logo=cilium)](https://cilium.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-EF7B4D.svg?logo=argo)](https://argoproj.github.io/cd/)
[![Kyverno](https://img.shields.io/badge/Governance-Kyverno_PSS-008080.svg)](https://kyverno.io/)
[![Azure AKS](https://img.shields.io/badge/Platform-Azure_AKS-0078D4.svg?logo=microsoftazure)](https://azure.microsoft.com)

**Enterprise AKS Engine • Cilium eBPF L7 Network Policies • Kyverno Restricted Admission Control • Entra ID Workload Identity • ArgoCD Declarative App-of-Apps**

[Architecture](#-architecture) • [Security Controls](#-zero-trust-security-pillars) • [GitOps Engine](#-gitops-declarative-workflow) • [Deployment](#-deployment-guide)

</div>

---

## 🎯 Architectural Overview

Modern containerized platforms face sophisticated internal lateral movement risks and supply chain threats. **Zero-Trust Kubernetes GitOps** implements a strict **"Never Trust, Always Verify"** security model on **Microsoft Azure Kubernetes Service (AKS)**, architected and automated by **Gunjan Kumar Gaurav**.

```
[ Git Repository: Declarative State ]
                  |
                  v  (Automated Sync & Drift Self-Healing)
      [ ArgoCD GitOps Engine ]
                  |
                  v  (Admission Interception)
    [ Kyverno Policy Engine ]
    • Disallow Root & Escalation
    • Enforce Read-Only RootFS
    • Drop ALL Linux Capabilities
                  |
                  v
[ Zero-Trust AKS Pod Network (Cilium eBPF) ]
• Default-Deny Ingress / Egress
• Layer 7 HTTP Path & Method Restriction
• Mutual TLS (mTLS) Encryption
                  |
                  v
[ Microsoft Entra ID Workload Identity ]
• Ephemeral OIDC token exchange
• Secret Store CSI Driver (Mounts directly from Azure Key Vault to RAM)
```

---

## 🔐 Zero-Trust Security Pillars

### 1. eBPF-Powered Micro-Segmentation (Cilium)
* **Default-Deny Clusterwide Policy:** All Pod-to-Pod and Pod-to-Internet communication is blocked by default.
* **Layer 7 HTTP Filtering:** Microservices communicate using explicit HTTP method and endpoint whitelisting (`POST /v1/charges` permitted; all administrative endpoints rejected).
* **DNS Egress Restriction:** Egress traffic is restricted exclusively to Kubernetes CoreDNS port 53.

### 2. Passwordless Entra ID Workload Identity
* **Elimination of Static Service Principal Secrets:** Pods exchange short-lived Kubernetes service account tokens with Microsoft Entra ID via OIDC federation.
* **Azure Key Vault Secret Store CSI:** Secrets are mounted as in-memory tmpfs files directly from Azure Key Vault, preventing secret exposure in `etcd` or persistent storage.

### 3. Kyverno Pod Security Standards (Restricted)
* `runAsNonRoot: true` strictly enforced.
* Read-only root filesystems enforced (`readOnlyRootFilesystem: true`).
* Linux kernel capabilities stripped (`capabilities.drop: ["ALL"]`).

### 4. GitOps Declarative Delivery via ArgoCD
* Infrastructure and application state maintained in Git as the Single Source of Truth.
* Automated drift detection and immediate self-healing to prevent configuration tampering.

---

## 📁 Repository Structure

```
zero-trust-kubernetes-gitops/
├── .github/workflows/
│   └── gitops-validation.yml             # Manifest syntax & Kyverno policy CI check
├── gitops/
│   ├── apps/
│   │   └── payment-service/              # Hardened Zero-Trust reference microservice
│   │       ├── deployment.yaml
│   │       └── secret-provider-class.yaml
│   ├── bootstrap/
│   │   └── argocd-root-app.yaml          # Root ArgoCD App-of-Apps manifest
│   ├── network-policies/
│   │   ├── cilium-default-deny-all.yaml  # Global default-deny network policy
│   │   └── cilium-l7-http-ingress.yaml   # Layer 7 micro-segmentation
│   └── policies/
│       ├── kyverno-disallow-root.yaml    # Admission control: root container denial
│       └── kyverno-read-only-rootfs.yaml
├── terraform/
│   ├── aks_cluster.tf                    # Production AKS with Cilium & Workload Identity
│   ├── workload_identity.tf              # Azure Entra ID federated credential
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```

---

## 🚀 Deployment Guide

### Step 1: Provision Zero-Trust AKS Infrastructure

```bash
cd terraform
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### Step 2: Bootstrap ArgoCD & Apply Security Baseline

```bash
az aks get-credentials --resource-group rg-aks-zerotrust-prod --name aks-zerotrust-prod-01
kubectl apply -f gitops/bootstrap/argocd-root-app.yaml
```

---

## 👤 Architect & Author

**Gunjan Kumar Gaurav**  
*Senior Cloud Architect & DevSecOps Consultant*  
[LinkedIn](https://www.linkedin.com/in/gunjan-gaurav) • [GitHub](https://github.com/gunjankumargaurav7350) • Email: `gunjankumargaurav7@gmail.com`
