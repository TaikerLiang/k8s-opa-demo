# Trino + OPA + Postgres Demo Implementation Plan

## Overview
This project demonstrates policy-based authorization and row-level security using Trino, Open Policy Agent (OPA), and PostgreSQL running on Docker Desktop Kubernetes.

## Environment Status
- ✅ Docker Desktop available (v28.4.0)
- ✅ kubectl installed (v1.32.2)
- ⚠️ Python 3.9.6 (originally specified 3.11+, but 3.9+ should work)
- ❓ Trino client needs installation
- ❓ Kubernetes needs to be enabled in Docker Desktop

## Phase 0 - Prerequisites Setup (10-15 min)
1. **Verify/enable Kubernetes in Docker Desktop**
   - Check if Kubernetes is running
   - Enable if needed and wait for startup
2. **Install Trino CLI client**
   - Download and install trino-cli
   - Verify installation
3. **Create Kubernetes namespace**
   ```bash
   kubectl create namespace demo-trino
   ```
4. **Set up project directory structure**
   - k8s/ (Kubernetes manifests)
   - policies/ (Rego policies)
   - client/ (Python test client)
   - scripts/ (helper scripts)

## Phase 1 - Core Infrastructure Deployment
### 1.1 PostgreSQL Setup
- Create deployment with persistent volume
- Initialize with sample orders table and data
- Configure service for internal cluster access

### 1.2 OPA Server Deployment
- Deploy OPA in server mode
- Create ConfigMap for policy storage
- Configure decision logging
- Set up service for Trino integration

### 1.3 Trino Deployment
- Deploy Trino coordinator with PostgreSQL catalog
- Configure OPA plugin integration
- Set request timeout (5s) to prevent hanging
- Expose service for client access

### 1.4 Verification
- Check all pods are running
- Verify inter-service connectivity
- Test basic Trino query without policies

## Phase 2 - Policy Implementation & Testing
### 2.1 Rego Policy Development
- **Authorization policy**: Allow/deny based on user context
- **Row-level filtering**: Filter data based on user attributes
- Store policies in ConfigMap and reload OPA

### 2.2 Python Test Client
- Create client with different user contexts (alice, bob)
- Implement query execution with user headers
- Add result comparison and validation

### 2.3 Testing & Validation
- Execute same queries with different users
- Verify row filtering works correctly
- Check OPA decision logs for transparency
- Validate authorization decisions

## Phase 3 - Quality of Life & Hardening
### 3.1 Observability
- Set up port-forwarding for Trino Web UI
- Configure OPA decision logging
- Add health checks for all components

### 3.2 Policy Testing
- Split Rego into separate modules
- Create unit tests with `opa test`
- Add policy validation scripts

### 3.3 Operational Improvements
- Create demo script with sample queries
- Add cleanup script for teardown
- Document troubleshooting steps
- Consider Helm charts for easier deployment

## Deliverables
- ✅ Single-node Trino in Kubernetes querying PostgreSQL
- ✅ OPA controlling authorization and row-level filtering
- ✅ Python client demonstrating user-based filtering
- ✅ Policy decisions visible in OPA logs
- ✅ Complete Kubernetes manifests
- ✅ Tested Rego policies with unit tests
- ✅ Documentation and cleanup scripts

## Technical Considerations
- Use appropriate resource limits for single-node deployment
- Ensure proper service discovery between components
- Handle OPA policy updates without service restart
- Configure appropriate logging levels for debugging
- Consider security contexts for production readiness

## Next Steps
Ready to begin Phase 0 implementation upon confirmation.