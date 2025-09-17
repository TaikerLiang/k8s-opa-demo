#!/bin/bash
set -e

echo "🔍 Phase 1 Verification Script"
echo "==============================="

# Check if all pods are running
echo "📋 Checking pod status..."
kubectl get pods -n demo-trino

echo ""
echo "🐘 Testing PostgreSQL connectivity..."
kubectl exec -n demo-trino deployment/postgres -- psql -U trino -d demo -c "SELECT COUNT(*) as total_orders FROM orders;"

echo ""
echo "🛡️ Testing OPA server..."
if kubectl get pod -n demo-trino -l app=opa --field-selector=status.phase=Running --no-headers | wc -l | grep -q "1"; then
    echo "✅ OPA pod is running"
    kubectl port-forward -n demo-trino svc/opa 8181:8181 &
    PORT_FORWARD_PID=$!
    sleep 2

    if curl -s http://localhost:8181/v1/data/trino/authz/allow -d '{"input":{"context":{"identity":{"user":"alice"}}}}' -H "Content-Type: application/json" | jq -r '.result' 2>/dev/null; then
        echo "✅ OPA is responding"
    else
        echo "❌ OPA not responding properly"
    fi

    kill $PORT_FORWARD_PID 2>/dev/null || true
else
    echo "❌ OPA pod not running yet"
fi

echo ""
echo "🚀 Testing Trino server..."
if kubectl get pod -n demo-trino -l app=trino --field-selector=status.phase=Running --no-headers | wc -l | grep -q "1"; then
    echo "✅ Trino pod is running"
    kubectl port-forward -n demo-trino svc/trino 8080:8080 &
    PORT_FORWARD_PID=$!
    sleep 3

    if curl -s http://localhost:8080/v1/info | jq -r '.nodeVersion.version' 2>/dev/null; then
        echo "✅ Trino is responding"
    else
        echo "❌ Trino not responding properly"
    fi

    kill $PORT_FORWARD_PID 2>/dev/null || true
else
    echo "❌ Trino pod not running yet"
fi

echo ""
echo "📊 Summary:"
echo "- PostgreSQL: ✅ Running with sample data"
echo "- OPA: Check logs if not ready"
echo "- Trino: Check logs if not ready"
echo ""
echo "💡 Once all pods are ready, proceed to Phase 2!"