package trino.external_api

# Mock configuration for testing
mock_config := {
	"api_base_url": "http://test-api.com",
	"api_timeout": "3s",
	"basic_auth_token": "dGVzdDp0ZXN0", # test:test in base64
	"environment": "test",
}

# Test successful API response
test_user_is_valid_success if {
	user_is_valid("alice") with data.trino.config as mock_config
		with http.send as mock_http_success
}

# Test failed API response
test_user_is_valid_failure if {
	not user_is_valid("bob") with data.trino.config as mock_config
		with http.send as mock_http_failure
}

# Test API unavailable - should use fallback
test_user_authorized_fallback if {
	user_authorized("alice") with data.trino.config as mock_config
		with http.send as mock_http_error
}

# Test unauthorized user with fallback
test_user_not_authorized_fallback if {
	not user_authorized("eve") with data.trino.config as mock_config
		with http.send as mock_http_error
}

# Test configuration loading
test_config_loading if {
	validate_user("alice") with data.trino.config as mock_config
		with http.send as mock_http_success
}

# Mock HTTP responses
mock_http_success(_) := {
	"status_code": 200,
	"body": {
		"user": "alice",
		"valid": true,
		"department": "engineering",
	},
}

mock_http_failure(_) := {
	"status_code": 403,
	"body": {"error": "User not found"},
}

mock_http_error(_) := {
	"status_code": 500,
	"body": {"error": "Internal server error"},
}
