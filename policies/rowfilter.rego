package trino.rowfilter

# Default no filter
default expression = ""

# Row filter for orders table based on sales_rep
expression = sprintf("sales_rep = '%s'", [input.context.identity.user]) {
    input.action.resource.table.tableName == "orders"
    input.context.identity.user in ["alice", "bob", "charlie", "diana"]
}

# Admin users see all data
expression = "" {
    input.action.resource.table.tableName == "orders"
    input.context.identity.user == "admin"
}