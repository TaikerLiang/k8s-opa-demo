package trino.authz

# Default deny all
default allow = false

# Allow basic queries for authenticated users
allow {
    input.action.operation in ["SELECT", "SHOW"]
    input.context.identity.user != ""
}

# Allow metadata operations
allow {
    input.action.operation in ["SHOW_TABLES", "SHOW_COLUMNS", "DESCRIBE"]
    input.context.identity.user != ""
}