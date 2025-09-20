package trino.rowfilter

# Default no filter
default expression := ""

# Row filter for orders table - only alice can see her data
expression := sprintf("sales_rep = '%s'", [input.context.identity.user]) if {
	input.action.resource.table.tableName == "orders"
	input.context.identity.user == "alice"
}
