# Zero-Trust Kubernetes GitOps

An enterprise-grade production Kubernetes platform implementing the Zero-Trust security model on Azure Kubernetes Service (AKS).

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

## Security Architecture

- **eBPF Micro-Segmentation (Cilium):** Default-deny cluster-wide policy with Layer 7 HTTP filtering.
- **Entra ID Workload Identity:** Passwordless pod authentication via short-lived OIDC tokens.
- **Key Vault CSI Driver:** Mounts secrets directly into container memory (zero secrets in `etcd`).
- **Kyverno Guardrails:** Enforces `runAsNonRoot: true`, read-only root filesystems, and drops all Linux capabilities.
- **GitOps Delivery:** ArgoCD App-of-Apps pattern with automated drift detection and self-healing.

## Repository Layout

```
zero-trust-kubernetes-gitops/
├── .github/workflows/
│   ├── gitops-validation.yml             # Manifest syntax & Kyverno validation
│   ├── payment-service-ci.yml            # Python test, lint, docker build & Trivy scan
│   └── terraform-ci-cd.yml               # Terraform validation
├── apps/
│   └── payment-service/                  # Reference microservice
│       ├── Dockerfile                    # Multi-stage non-root build
│       ├── requirements.txt              # Dependencies
│       ├── src/                          # FastAPI payment service
│       └── tests/                        # Unit tests
├── gitops/
│   ├── apps/
│   │   └── payment-service/              # K8s Deployment, Service, HPA, NetPol
│   ├── bootstrap/
│   │   └── argocd-root-app.yaml          # ArgoCD root manifest
│   ├── network-policies/
│   │   ├── cilium-default-deny-all.yaml  # Global default-deny
│   │   └── cilium-l7-http-ingress.yaml   # L7 micro-segmentation
│   └── policies/
│       └── kyverno-disallow-root.yaml    # Admission control
└── terraform/                            # Modular infrastructure
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── aks_cluster/
        └── workload_identity/
```

## Running the Payment Service Locally

### 1. Run with Python

```bash
cd apps/payment-service
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn src.app:app --reload --port 8080
```

Endpoints available:
- `GET /healthz` - Liveness probe
- `GET /ready` - Readiness probe
- `POST /v1/payments` - Process payment (supports `Idempotency-Key` header)
- `GET /v1/payments/{transaction_id}` - Get transaction status
- `GET /docs` - Swagger UI

### 2. Run with Docker

```bash
docker build -t payment-service:v1.0.0 apps/payment-service
docker run -p 8080:8080 payment-service:v1.0.0
```

## Deploying Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Deploying GitOps Workloads

```bash
az aks get-credentials --resource-group rg-aks-zerotrust-prod --name aks-zerotrust-prod-01
kubectl apply -f gitops/bootstrap/argocd-root-app.yaml
```

## Author

**Gunjan Kumar Gaurav**  
*Senior Cloud & DevSecOps Consultant*  
[LinkedIn](https://www.linkedin.com/in/gunjan-gaurav) • [GitHub](https://github.com/gunjankumargaurav7350)
