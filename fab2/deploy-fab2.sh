#!/bin/bash
set -e

echo "🚀 Deploying fab2 with API integration to example2.com"
echo "===================================================="
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Create namespace
echo "📁 Creating demo-trino namespace..."
kubectl create namespace demo-trino --dry-run=client -o yaml | kubectl apply -f -

# Deploy shared runtime configuration
echo "🔧 Deploying shared OPA runtime configuration..."
kubectl apply -f ../k8s/opa-runtime-config.yaml

# Deploy fab2-specific configuration and secrets
echo "🔧 Deploying API configuration for fab2..."
kubectl apply -f k8s/opa-config.yaml
kubectl apply -f k8s/opa-secrets.yaml
kubectl apply -f k8s/opa-policies.yaml

# Deploy OPA with API integration
echo "🛡️ Deploying OPA with external API integration..."
kubectl apply -f k8s/opa-deployment-clean.yaml

# Wait for OPA deployment
echo "⏳ Waiting for OPA to start..."
kubectl wait --for=condition=ready pod -l app=opa -n demo-trino --timeout=300s
echo "✅ OPA ready with API integration"

echo ""
echo "🎯 fab2 deployment completed!"
echo ""
echo "📋 Current status:"
kubectl get pods -n demo-trino

echo ""
echo "🔍 API Configuration:"
echo "  - API Endpoint: http://example2.com/{user}"
echo "  - Basic Auth: u2:p2"
echo "  - Environment: fab2"
echo ""
echo "🧪 Test API integration:"
echo "kubectl port-forward -n demo-trino svc/opa 8181:8181"
echo "curl -X POST http://localhost:8181/v1/data/trino/authz/allow \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '{\"input\": {\"action\": {\"operation\": \"SELECT\"}, \"context\": {\"identity\": {\"user\": \"alice\"}}}}'"