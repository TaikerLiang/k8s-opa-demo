# Trino + OPA + Postgres Demo

Policy-based authorization and row-level security demonstration using Trino, Open Policy Agent (OPA), and PostgreSQL on Kubernetes.

## Project Structure

```
├── k8s/         # Kubernetes manifests
├── policies/    # OPA Rego policies
├── client/      # Python test client
├── scripts/     # Helper scripts
└── PLAN.md      # Implementation plan
```

## Quick Start

1. **Phase 0**: Prerequisites setup ✅
2. **Phase 1**: Deploy infrastructure (Postgres, OPA, Trino)
3. **Phase 2**: Implement policies and test with different users
4. **Phase 3**: Add observability and hardening

## Requirements

- Docker Desktop with Kubernetes enabled
- kubectl CLI
- Python 3.9+
- Trino CLI

## Usage

See `PLAN.md` for detailed implementation steps.