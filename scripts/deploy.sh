#!/bin/bash
set -e

echo "🚀 Deploying Trino + OPA Demo"
echo "=============================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Create namespace
echo "📁 Creating demo-trino namespace..."
kubectl create namespace demo-trino --dry-run=client -o yaml | kubectl apply -f -

# Deploy all components
echo "🐘 Deploying PostgreSQL..."
kubectl apply -f k8s/postgres.yaml

echo "🛡️ Deploying OPA..."
kubectl apply -f k8s/opa.yaml

echo "🚀 Deploying Trino..."
kubectl apply -f k8s/trino.yaml

# Wait for deployments
echo "⏳ Waiting for pods to start..."
echo "This may take a few minutes for image downloads..."

kubectl wait --for=condition=ready pod -l app=postgres -n demo-trino --timeout=300s
echo "✅ PostgreSQL ready"

kubectl wait --for=condition=ready pod -l app=opa -n demo-trino --timeout=300s
echo "✅ OPA ready"

kubectl wait --for=condition=ready pod -l app=trino -n demo-trino --timeout=300s
echo "✅ Trino ready"

echo ""
echo "🎯 Deployment completed!"
echo ""
echo "📋 Current status:"
kubectl get pods -n demo-trino

echo ""
echo "🎮 Next steps:"
echo "1. Run the demo: ./scripts/demo.sh"
echo "2. Test manually: ./scripts/test-phase2.sh"
echo "3. Cleanup when done: ./scripts/cleanup.sh"