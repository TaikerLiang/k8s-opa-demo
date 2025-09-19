# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kubernetes-based demonstration of policy-based authorization using Trino, Open Policy Agent (OPA), and PostgreSQL. The project shows how to implement row-level security and access control in a data querying environment.

## Architecture

The system consists of three main components deployed in Kubernetes:
- **PostgreSQL**: Database with sample orders table containing 10 records across 4 sales reps (alice, bob, charlie, diana)
- **Open Policy Agent (OPA)**: Policy engine for authorization decisions
- **Trino**: Query coordinator that connects to PostgreSQL and integrates with OPA for access control

## Common Commands

### Deployment and Management
```bash
# Deploy the entire demo environment
./scripts/deploy.sh

# Run interactive demo with sample queries
./scripts/demo.sh

# Clean up all resources
./scripts/cleanup.sh

# Manual deployment of individual components
kubectl apply -f k8s/postgres.yaml
kubectl apply -f k8s/opa.yaml
kubectl apply -f k8s/trino.yaml
```

### Development and Testing
```bash
# Check cluster status
kubectl get pods -n demo-trino

# View logs for troubleshooting
kubectl logs -n demo-trino deployment/postgres
kubectl logs -n demo-trino deployment/opa
kubectl logs -n demo-trino deployment/trino

# Port forward for local access
kubectl port-forward -n demo-trino svc/trino 8080:8080
kubectl port-forward -n demo-trino svc/opa 8181:8181

# Test Trino queries manually (requires Trino CLI)
~/.local/bin/trino --server localhost:8080 --catalog postgresql --schema public --user alice

# Run automated tests
./scripts/test-phase2.sh
./scripts/verify-phase1.sh
```

### Python Client Testing
```bash
# Navigate to client directory
cd client/

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run test client with different users
python trino_client.py
```

## Key Configuration Files

- `k8s/postgres.yaml`: PostgreSQL deployment with sample data initialization
- `k8s/opa.yaml`: OPA server configuration with policy storage
- `k8s/trino.yaml`: Trino coordinator with PostgreSQL catalog configuration
- `client/trino_client.py`: Python test client for user-based query testing

## Project Structure

```
├── k8s/              # Kubernetes manifests for all components
├── scripts/          # Deployment, demo, and utility scripts
├── client/           # Python test client with virtual environment
├── fab1/ & fab2/     # Additional test data directories
└── policies/         # OPA Rego policies (deleted in current state)
```

## Important Notes

- The project requires Docker Desktop with Kubernetes enabled
- Trino CLI is automatically installed to `~/.local/bin/trino` during deployment
- All components run in the `demo-trino` namespace
- Sample data includes 10 orders distributed across 4 sales representatives
- Current implementation shows foundation for policy-based access control but requires additional OPA-Trino integration for full row-level security

## Testing Approach

The project includes both automated scripts and manual testing approaches:
- Use `./scripts/demo.sh` for comprehensive demonstration
- Use `./scripts/test-phase2.sh` for automated testing
- Use Python client in `client/` directory for programmatic testing
- Verify deployments with `./scripts/verify-phase1.sh`

## Troubleshooting

- Check pod status: `kubectl get pods -n demo-trino`
- View detailed pod information: `kubectl describe pod <pod-name> -n demo-trino`
- Check service connectivity between components using port-forwarding
- Ensure Docker Desktop Kubernetes is enabled and running