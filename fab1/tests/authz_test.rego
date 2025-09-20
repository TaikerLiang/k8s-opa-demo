package trino.authz

import data.trino.external_api

# Original local tests
test_alice_can_select_local if {
	allow with input as {
		"action": {"operation": "SELECT"},
		"context": {"identity": {"user": "alice"}},
	}
}

test_bob_cannot_select_local if {
	not allow with input as {
		"action": {"operation": "SELECT"},
		"context": {"identity": {"user": "bob"}},
	}
}

test_alice_can_show_tables_local if {
	allow with input as {
		"action": {"operation": "SHOW_TABLES"},
		"context": {"identity": {"user": "alice"}},
	}
}

test_anonymous_cannot_access if {
	not allow with input as {
		"action": {"operation": "SELECT"},
		"context": {"identity": {"user": ""}},
	}
}

# API integration tests
test_alice_can_select_with_api if {
	allow with input as {
		"action": {"operation": "SELECT"},
		"context": {"identity": {"user": "alice"}},
	}
		with external_api.user_authorized as mock_user_authorized_success
}

test_bob_cannot_select_with_api if {
	not allow with input as {
		"action": {"operation": "SELECT"},
		"context": {"identity": {"user": "bob"}},
	}
		with external_api.user_authorized as mock_user_authorized_failure
}

test_alice_fallback_when_api_fails if {
	allow with input as {
		"action": {"operation": "SELECT"},
		"context": {"identity": {"user": "alice"}},
	}
		with external_api.user_authorized as mock_user_authorized_error
}

# Mock functions for testing
mock_user_authorized_success(user) := result if {
	user == "alice"
	result := true
} else := false

mock_user_authorized_failure(_) := false

mock_user_authorized_error(_) := false
