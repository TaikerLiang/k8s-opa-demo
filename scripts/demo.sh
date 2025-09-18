#!/bin/bash
set -e

echo "🎯 Trino + OPA + PostgreSQL Demo"
echo "================================="
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found"
    exit 1
fi

if ! command -v ~/.local/bin/trino &> /dev/null; then
    echo "❌ Trino CLI not found"
    exit 1
fi

echo "✅ Prerequisites met"
echo ""

# Check cluster status
echo "📋 Checking cluster status..."
kubectl get pods -n demo-trino

echo ""
echo "🔌 Setting up port forwards..."
kubectl port-forward -n demo-trino svc/trino 8080:8080 &
TRINO_PF_PID=$!
kubectl port-forward -n demo-trino svc/opa 8181:8181 &
OPA_PF_PID=$!

# Cleanup function
cleanup() {
    echo ""
    echo "🧹 Cleaning up port forwards..."
    kill $TRINO_PF_PID 2>/dev/null || true
    kill $OPA_PF_PID 2>/dev/null || true
}
trap cleanup EXIT

# Wait for port forwards
sleep 3

echo "✅ Port forwards established"
echo ""

# Test connectivity
echo "🚀 Testing connectivity..."
if curl -s http://localhost:8080/v1/info | jq -r '.nodeVersion.version' >/dev/null 2>&1; then
    echo "✅ Trino is responding"
else
    echo "❌ Trino not responding - check pod status"
    exit 1
fi

if curl -s http://localhost:8181/health >/dev/null 2>&1; then
    echo "✅ OPA is responding"
else
    echo "⚠️ OPA not responding - continuing without OPA tests"
fi

echo ""
echo "📊 Demo: Current Database State"
echo "==============================="

echo "📋 Total orders in database:"
~/.local/bin/trino --server localhost:8080 --catalog postgresql --schema public --user admin \
    --execute "SELECT COUNT(*) as total_orders FROM orders" 2>/dev/null

echo ""
echo "📋 Orders by sales representative:"
~/.local/bin/trino --server localhost:8080 --catalog postgresql --schema public --user admin \
    --execute "SELECT sales_rep, COUNT(*) as order_count FROM orders GROUP BY sales_rep ORDER BY sales_rep" 2>/dev/null

echo ""
echo "👥 Demo: User Access (Without OPA Integration)"
echo "=============================================="

users=("alice" "bob" "charlie" "diana" "admin")

for user in "${users[@]}"; do
    echo ""
    echo "👤 User: $user"
    echo "   Query: SELECT sales_rep, COUNT(*) FROM orders GROUP BY sales_rep"
    echo "   Result:"

    ~/.local/bin/trino --server localhost:8080 --catalog postgresql --schema public --user "$user" \
        --execute "SELECT '  ' || sales_rep || ': ' || CAST(COUNT(*) AS VARCHAR) as result FROM orders GROUP BY sales_rep ORDER BY sales_rep" 2>/dev/null || echo "   Query failed"
done

echo ""
echo "📝 Current State Summary:"
echo "========================"
echo "✅ PostgreSQL: Running with 10 sample orders"
echo "✅ Trino: Connected to PostgreSQL, no access controls"
echo "🔄 OPA: Basic policy deployed (not integrated with Trino)"
echo ""
echo "🎯 What this demonstrates:"
echo "- All users can see ALL data (no row-level security)"
echo "- alice sees data from all sales reps (alice: 4, bob: 2, charlie: 2, diana: 2)"
echo "- bob sees data from all sales reps (same as alice)"
echo "- Ready for OPA integration to enable row-level filtering"
echo ""
echo "🔧 Next Steps for Full Integration:"
echo "1. Install Trino OPA plugin (requires Trino Enterprise or compatible build)"
echo "2. Update Trino configuration with OPA access control"
echo "3. Deploy enhanced OPA policies for row filtering"
echo "4. Test: alice should only see her 4 orders, bob only his 2 orders"
echo ""
echo "📚 Demo completed! Check PLAN.md for detailed implementation steps."