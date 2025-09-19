# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Kubernetes-based demonstration of policy-based authorization using Trino, Open Policy Agent (OPA), and PostgreSQL. The project demonstrates advanced security patterns including external API integration, environment-specific configurations, and comprehensive policy testing.

## Architecture

The system consists of three main components with advanced policy integration:
- **PostgreSQL**: Database with sample orders table containing 10 records across 4 sales reps (alice, bob, charlie, diana)
- **Open Policy Agent (OPA)**: Policy engine with external API validation and fallback mechanisms
- **Trino**: Query coordinator that connects to PostgreSQL and integrates with OPA for access control

### External API Integration
- **fab1**: Validates users via `http://example1.com/{user}` with basic auth (u1:p1)
- **fab2**: Validates users via `http://example2.com/{user}` with basic auth (u2:p2)
- **Fallback**: Graceful degradation to alice-only access if external APIs unavailable

## Common Commands

### Deployment and Management
```bash
# Deploy basic demo environment (legacy)
./scripts/deploy.sh

# Deploy fab1 environment with external API integration
cd fab1/ && ./deploy-fab1.sh

# Deploy fab2 environment with external API integration
cd fab2/ && ./deploy-fab2.sh

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

# Test OPA policies directly
curl -X POST http://localhost:8181/v1/data/trino/authz/allow \
  -H 'Content-Type: application/json' \
  -d '{"input": {"action": {"operation": "SELECT"}, "context": {"identity": {"user": "alice"}}}}'

# Run automated tests
./scripts/test-phase2.sh
./scripts/verify-phase1.sh

# Test fab1/fab2 policies locally
cd fab1/ && opa test policies/ -v
cd fab2/ && opa test policies/ -v
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

### Core Infrastructure
- `k8s/postgres.yaml`: PostgreSQL deployment with sample data initialization
- `k8s/opa.yaml`: Basic OPA server configuration (legacy)
- `k8s/trino.yaml`: Trino coordinator with PostgreSQL catalog configuration
- `k8s/opa-runtime-config.yaml`: Shared OPA runtime configuration

### fab1 Environment (example1.com integration)
- `fab1/k8s/opa-config.yaml`: API endpoint configuration for example1.com
- `fab1/k8s/opa-secrets.yaml`: Basic auth credentials (u1:p1)
- `fab1/k8s/opa-policies.yaml`: Rego policies with external API integration
- `fab1/k8s/opa-deployment-clean.yaml`: Optimized OPA deployment
- `fab1/deploy-fab1.sh`: Automated deployment script

### fab2 Environment (example2.com integration)
- `fab2/k8s/opa-config.yaml`: API endpoint configuration for example2.com
- `fab2/k8s/opa-secrets.yaml`: Basic auth credentials (u2:p2)
- `fab2/k8s/opa-policies.yaml`: Rego policies with external API integration
- `fab2/k8s/opa-deployment-clean.yaml`: Optimized OPA deployment
- `fab2/deploy-fab2.sh`: Automated deployment script

### Policy Files
- `fab1/policies/`: Local policy development and testing
  - `authz.rego`: Authorization logic with API integration
  - `external_api.rego`: HTTP request logic using http.send
  - `config.rego`: Configuration data loader
  - `rowfilter.rego`: Row-level security policies
  - `*_test.rego`: Comprehensive test suites

### Client Testing
- `client/trino_client.py`: Python test client for user-based query testing

## Project Structure

```
├── k8s/                           # Core Kubernetes manifests
│   ├── postgres.yaml              # PostgreSQL with sample data
│   ├── opa.yaml                   # Basic OPA deployment (legacy)
│   ├── trino.yaml                 # Trino coordinator
│   └── opa-runtime-config.yaml    # Shared OPA runtime configuration
├── scripts/                       # Deployment and demo scripts
│   ├── deploy.sh                  # Basic deployment
│   ├── demo.sh                    # Interactive demo
│   └── cleanup.sh                 # Resource cleanup
├── client/                        # Python test client
│   ├── trino_client.py            # Test client with virtual environment
│   └── requirements.txt           # Python dependencies
├── fab1/                          # Environment 1 (example1.com)
│   ├── k8s/                       # Kubernetes manifests
│   │   ├── opa-config.yaml        # API endpoint config
│   │   ├── opa-secrets.yaml       # Credentials (u1:p1)
│   │   ├── opa-policies.yaml      # Policy ConfigMap
│   │   └── opa-deployment-clean.yaml # Optimized deployment
│   ├── policies/                  # Local policy development
│   │   ├── authz.rego             # Authorization with API integration
│   │   ├── external_api.rego      # HTTP request logic
│   │   ├── config.rego            # Configuration loader
│   │   ├── rowfilter.rego         # Row-level security
│   │   └── *_test.rego            # Test suites
│   └── deploy-fab1.sh            # Deployment script
├── fab2/                          # Environment 2 (example2.com)
│   ├── k8s/                       # Kubernetes manifests
│   │   ├── opa-config.yaml        # API endpoint config
│   │   ├── opa-secrets.yaml       # Credentials (u2:p2)
│   │   ├── opa-policies.yaml      # Policy ConfigMap
│   │   └── opa-deployment-clean.yaml # Optimized deployment
│   ├── policies/                  # Local policy development
│   │   └── [same structure as fab1]
│   └── deploy-fab2.sh            # Deployment script
└── CLAUDE.md                      # This documentation
```

## Important Notes

- The project requires Docker Desktop with Kubernetes enabled
- Trino CLI is automatically installed to `~/.local/bin/trino` during deployment
- All components run in the `demo-trino` namespace
- Sample data includes 10 orders distributed across 4 sales representatives

### Advanced Features
- **External API Integration**: OPA policies make HTTP requests to validate users
- **Environment Isolation**: fab1 and fab2 can be deployed to different clusters
- **Fallback Mechanisms**: Graceful degradation if external APIs are unavailable
- **ConfigMap Optimization**: Shared runtime config, environment-specific policies
- **Comprehensive Testing**: 12/12 tests passing for both environments

### Security Implementation
- Credentials stored securely in Kubernetes Secrets (base64 encoded)
- API timeout configuration (5s default) prevents hanging requests
- Row-level security ensures users only see their own data
- Alice-only fallback maintains system availability during API outages

## Testing Approach

The project includes comprehensive testing at multiple levels:

### Legacy Testing
- Use `./scripts/demo.sh` for basic demonstration
- Use `./scripts/test-phase2.sh` for automated testing
- Use Python client in `client/` directory for programmatic testing
- Verify deployments with `./scripts/verify-phase1.sh`

### Advanced Policy Testing
- **Unit Tests**: `opa test policies/ -v` in fab1/fab2 directories
- **API Integration Tests**: Mock external API responses
- **Authorization Flow Tests**: Complete authentication and authorization scenarios
- **Fallback Testing**: Verify behavior when external APIs fail
- **Configuration Testing**: Validate environment-specific settings

### Test Coverage
- **12/12 tests passing** for both fab1 and fab2 environments
- **Mock HTTP responses** for comprehensive API testing
- **Environment isolation** testing for cluster deployment
- **Error handling** and timeout scenarios

## Troubleshooting

### Basic Diagnostics
- Check pod status: `kubectl get pods -n demo-trino`
- View detailed pod information: `kubectl describe pod <pod-name> -n demo-trino`
- Check service connectivity between components using port-forwarding
- Ensure Docker Desktop Kubernetes is enabled and running

### ConfigMap Issues
- Verify ConfigMap creation: `kubectl get configmaps -n demo-trino`
- Check ConfigMap content: `kubectl describe configmap opa-policies-fab1 -n demo-trino`
- Ensure unique naming: `opa-policies-fab1` vs `opa-policies-fab2`

### API Integration Debugging
- Test external API connectivity manually before deployment
- Check OPA decision logs: `kubectl logs -n demo-trino deployment/opa`
- Verify environment variables: `kubectl exec -n demo-trino deployment/opa -- env | grep API`
- Test policy decisions locally: `opa test policies/ -v`

### Policy Issues
- Validate Rego syntax: `opa fmt policies/`
- Test policies in isolation before deployment
- Check for import conflicts between packages
- Verify configuration data loading in `config.rego`

### Secret Management
- Verify Secret creation: `kubectl get secrets -n demo-trino`
- Check base64 encoding: `echo "u1:p1" | base64`
- Ensure proper Secret mounting in deployment volumes