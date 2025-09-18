#!/bin/bash
set -e

echo "🧹 Trino + OPA Demo Cleanup"
echo "==========================="
echo ""

# Kill any port forwards
echo "🔌 Stopping port forwards..."
pkill -f "kubectl port-forward" 2>/dev/null || echo "No port forwards running"

# Delete the demo namespace
echo "🗑️ Deleting demo-trino namespace..."
kubectl delete namespace demo-trino --ignore-not-found=true

# Wait for cleanup
echo "⏳ Waiting for cleanup to complete..."
sleep 5

# Verify cleanup
echo "✅ Cleanup verification:"
if kubectl get namespace demo-trino 2>/dev/null; then
    echo "⚠️ Namespace still exists, may take a moment to fully delete"
else
    echo "✅ Namespace deleted successfully"
fi

echo ""
echo "🎯 Cleanup completed!"
echo ""
echo "To restart the demo:"
echo "1. Run: kubectl create namespace demo-trino"
echo "2. Run: kubectl apply -f k8s/"
echo "3. Wait for pods to start: kubectl get pods -n demo-trino"
echo "4. Run: ./scripts/demo.sh"