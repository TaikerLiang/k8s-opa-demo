package trino.authz

# Default deny all
default allow = false

# Allow only alice user for basic queries
allow if {
    input.action.operation in ["SELECT", "SHOW"]
    input.context.identity.user == "alice"
}

# Allow only alice user for metadata operations
allow if {
    input.action.operation in ["SHOW_TABLES", "SHOW_COLUMNS", "DESCRIBE"]
    input.context.identity.user == "alice"
}