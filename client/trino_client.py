#!/usr/bin/env python3
"""
Trino client for testing OPA row-level security
"""

import trino
import sys
import json
from typing import List, Dict, Any

class TrinoClient:
    def __init__(self, host: str = "localhost", port: int = 8080, user: str = "admin"):
        self.host = host
        self.port = port
        self.user = user
        self.conn = trino.dbapi.connect(
            host=host,
            port=port,
            user=user,
            catalog='postgresql',
            schema='public'
        )

    def execute_query(self, query: str) -> List[Dict[str, Any]]:
        """Execute a query and return results"""
        try:
            cursor = self.conn.cursor()
            cursor.execute(query)

            # Get column names
            columns = [desc[0] for desc in cursor.description] if cursor.description else []

            # Get all rows
            rows = cursor.fetchall()

            # Convert to list of dictionaries
            results = [dict(zip(columns, row)) for row in rows]

            return results

        except Exception as e:
            print(f"Error executing query: {e}")
            return []

    def test_row_filtering(self):
        """Test row filtering for different users"""
        print(f"🔍 Testing as user: {self.user}")
        print("=" * 50)

        # Test basic query
        query = "SELECT customer_id, product_name, sales_rep, region FROM orders ORDER BY order_id"
        results = self.execute_query(query)

        print(f"📊 Query: {query}")
        print(f"📋 Results ({len(results)} rows):")

        if results:
            for row in results:
                print(f"   {row}")
        else:
            print("   No results returned")

        print("\n")

        # Test aggregation
        agg_query = "SELECT sales_rep, COUNT(*) as order_count, SUM(quantity) as total_items FROM orders GROUP BY sales_rep"
        agg_results = self.execute_query(agg_query)

        print(f"📊 Aggregation Query: {agg_query}")
        print(f"📋 Results ({len(agg_results)} rows):")

        if agg_results:
            for row in agg_results:
                print(f"   {row}")
        else:
            print("   No results returned")

def main():
    if len(sys.argv) < 2:
        print("Usage: python trino_client.py <username> [host] [port]")
        print("Example: python trino_client.py alice")
        print("Example: python trino_client.py bob localhost 8080")
        sys.exit(1)

    user = sys.argv[1]
    host = sys.argv[2] if len(sys.argv) > 2 else "localhost"
    port = int(sys.argv[3]) if len(sys.argv) > 3 else 8080

    print(f"🚀 Connecting to Trino at {host}:{port}")

    try:
        client = TrinoClient(host=host, port=port, user=user)
        client.test_row_filtering()

    except Exception as e:
        print(f"❌ Failed to connect or execute queries: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()