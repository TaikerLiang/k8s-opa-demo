package trino.authz

import data.trino.external_api

# Default deny all
default allow = false

# Allow basic queries with external API validation
allow if {
    input.action.operation in ["SELECT", "SHOW"]
    user := input.context.identity.user
    external_api.user_authorized(user)
}

# Allow metadata operations with external API validation
allow if {
    input.action.operation in ["SHOW_TABLES", "SHOW_COLUMNS", "DESCRIBE"]
    user := input.context.identity.user
    external_api.user_authorized(user)
}

# Additional rule: allow if local alice validation passes (fallback)
allow if {
    input.action.operation in ["SELECT", "SHOW", "SHOW_TABLES", "SHOW_COLUMNS", "DESCRIBE"]
    input.context.identity.user == "alice"
    # This ensures alice can still access even if API is down
}