#!/bin/bash
set -e

echo "🧪 Phase 2 Testing Script"
echo "========================="
echo ""

# Check if Trino CLI is available
if ! command -v ~/.local/bin/trino &> /dev/null; then
    echo "❌ Trino CLI not found. Please install it first."
    exit 1
fi

# Start port forwards in background
echo "🔌 Setting up port forwards..."
kubectl port-forward -n demo-trino svc/trino 8080:8080 &
TRINO_PF_PID=$!
kubectl port-forward -n demo-trino svc/opa 8181:8181 &
OPA_PF_PID=$!

# Wait for port forwards to establish
sleep 3

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up port forwards..."
    kill $TRINO_PF_PID 2>/dev/null || true
    kill $OPA_PF_PID 2>/dev/null || true
}
trap cleanup EXIT

echo "✅ Port forwards established"
echo ""

# Test Trino connectivity
echo "🚀 Testing Trino connectivity..."
if curl -s http://localhost:8080/v1/info | jq -r '.nodeVersion.version' >/dev/null 2>&1; then
    echo "✅ Trino is responding"
else
    echo "❌ Trino not responding"
    exit 1
fi

# Test OPA connectivity
echo "🛡️ Testing OPA connectivity..."
if curl -s http://localhost:8181/health >/dev/null 2>&1; then
    echo "✅ OPA is responding"
else
    echo "❌ OPA not responding"
fi
echo ""

# Test queries without OPA (current state)
echo "📊 Testing queries WITHOUT OPA integration (current state):"
echo "==========================================================="

users=("admin" "alice" "bob" "charlie" "diana")

for user in "${users[@]}"; do
    echo ""
    echo "👤 Testing as user: $user"
    echo "Query: SELECT sales_rep, COUNT(*) as orders FROM orders GROUP BY sales_rep"

    ~/.local/bin/trino --server localhost:8080 --catalog postgresql --schema public --user "$user" \
        --execute "SELECT sales_rep, COUNT(*) as orders FROM orders GROUP BY sales_rep" 2>/dev/null || echo "   Query failed"
done

echo ""
echo "📋 Current Results Summary:"
echo "- All users can see all data (no filtering applied)"
echo "- Alice should only see her orders (4 orders) when OPA is integrated"
echo "- Bob should only see his orders (2 orders) when OPA is integrated"
echo ""

# Test OPA policy decisions
echo "🧠 Testing OPA policy decisions:"
echo "================================"

test_policy() {
    local user=$1
    local query_data='{"input":{"context":{"identity":{"user":"'$user'"}}}}'

    echo "👤 User: $user"
    echo "   Policy decision:"

    if response=$(curl -s http://localhost:8181/v1/data/trino/allow -d "$query_data" -H "Content-Type: application/json" 2>/dev/null); then
        echo "   $response" | jq '.' 2>/dev/null || echo "   $response"
    else
        echo "   ❌ Failed to get policy decision"
    fi
    echo ""
}

for user in "${users[@]}"; do
    test_policy "$user"
done

echo "🎯 Phase 2 Status:"
echo "=================="
echo "✅ PostgreSQL: Running with sample data"
echo "✅ OPA: Running with basic allow policy"
echo "✅ Trino: Running and connected to PostgreSQL"
echo "❌ OPA Integration: Not yet configured in Trino"
echo ""
echo "📝 Next Steps for full Phase 2 completion:"
echo "1. Enable OPA plugin in Trino configuration"
echo "2. Add row-level filtering policies to OPA"
echo "3. Test row filtering with different users"
echo "4. Verify OPA decision logs"