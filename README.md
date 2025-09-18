# Trino + OPA + Postgres Demo

Policy-based authorization and row-level security demonstration using Trino, Open Policy Agent (OPA), and PostgreSQL on Kubernetes.

## Project Structure

```
├── k8s/              # Kubernetes manifests
│   ├── postgres.yaml # PostgreSQL with sample data
│   ├── opa.yaml      # OPA server with basic policies
│   └── trino.yaml    # Trino coordinator
├── client/           # Python test client (with venv)
├── scripts/          # Demo and utility scripts
│   ├── deploy.sh     # Deploy all components
│   ├── demo.sh       # Run interactive demo
│   ├── cleanup.sh    # Clean up resources
│   └── test-phase2.sh # Testing script
└── PLAN.md           # Implementation plan
```

## Quick Start

```bash
# 1. Deploy the demo
./scripts/deploy.sh

# 2. Run the interactive demo
./scripts/demo.sh

# 3. Clean up when done
./scripts/cleanup.sh
```

## What This Demonstrates

✅ **Working Infrastructure**
- PostgreSQL with 10 sample orders across 4 sales reps (alice, bob, charlie, diana)
- OPA server with basic authorization policies
- Trino coordinator connected to PostgreSQL

✅ **Current Behavior (Without Row-Level Security)**
- All users can query all data
- alice sees orders from all sales reps: alice(4), bob(2), charlie(2), diana(2)
- bob sees the same data as alice
- No filtering based on user identity

🎯 **Demo Value**
- Shows foundation for policy-based access control
- Ready for OPA-Trino integration
- Demonstrates current state vs. desired filtered state

## Requirements

- Docker Desktop with Kubernetes enabled ✅
- kubectl CLI ✅
- Trino CLI (automatically installed to ~/.local/bin/trino) ✅
- Python 3.9+ (for optional client testing)

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Trino CLI     │    │  Python Client  │    │   Trino Web UI  │
│   (port 8080)   │    │                 │    │   (port 8080)   │
└─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘
          │                      │                      │
          └──────────────────────┼──────────────────────┘
                                 │
                    ┌─────────────▼───────────────┐
                    │       Trino Coordinator     │
                    │     (PostgreSQL Catalog)    │
                    └─────────────┬───────────────┘
                                  │
                    ┌─────────────▼───────────────┐    ┌─────────────────┐
                    │       PostgreSQL            │    │       OPA       │
                    │   (orders table w/ RLS)     │    │   (policies)    │
                    └─────────────────────────────┘    └─────────────────┘
```

## Next Steps for Full Integration

1. **OPA-Trino Integration**: Configure Trino to use OPA for access control
2. **Row-Level Policies**: Implement policies where users only see their own data
3. **Column Masking**: Add sensitive data protection
4. **Audit Logging**: Enable decision logging for compliance

See `PLAN.md` for detailed implementation roadmap.