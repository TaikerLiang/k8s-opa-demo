package trino.external_api

import data.trino.config

# Validate user through external API
validate_user(user) := response if {
    user != ""
    config.basic_auth_token != ""
    config.api_base_url != ""

    request := {
        "method": "GET",
        "url": sprintf("%s/%s", [config.api_base_url, user]),
        "headers": {
            "Authorization": sprintf("Basic %s", [config.basic_auth_token]),
            "Content-Type": "application/json"
        },
        "timeout": config.api_timeout
    }

    response := http.send(request)
}

# Check if user is valid based on API response
user_is_valid(user) if {
    response := validate_user(user)
    response.status_code == 200
}

# Get user attributes from API response
user_attributes(user) := attributes if {
    response := validate_user(user)
    response.status_code == 200
    attributes := response.body
}

# Fallback for when API is unavailable - use local validation only
user_is_valid_fallback(user) if {
    # If API call fails, fall back to local user validation
    user == "alice"  # Only alice is allowed locally
}

# Main user validation function with fallback
user_authorized(user) if {
    user_is_valid(user)
} else := user_is_valid_fallback(user) if {
    # API validation failed, use fallback
    true
}