package trino.authz

test_alice_can_select if {
    allow with input as {
        "action": {"operation": "SELECT"},
        "context": {"identity": {"user": "alice"}}
    }
}

test_bob_cannot_select if {
    not allow with input as {
        "action": {"operation": "SELECT"},
        "context": {"identity": {"user": "bob"}}
    }
}

test_alice_can_show_tables if {
    allow with input as {
        "action": {"operation": "SHOW_TABLES"},
        "context": {"identity": {"user": "alice"}}
    }
}

test_anonymous_cannot_access if {
    not allow with input as {
        "action": {"operation": "SELECT"},
        "context": {"identity": {"user": ""}}
    }
}