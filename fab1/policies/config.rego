package trino.config

# Load configuration from environment variables and ConfigMap
# These will be available as data.config.* in other policies

# API configuration from ConfigMap
api_base_url := opa.runtime().config.api_base_url
api_timeout := opa.runtime().config.api_timeout
environment := opa.runtime().config.environment

# Credentials from environment variables (populated from Secret)
basic_auth_token := opa.runtime().config.basic_auth_token

# Default values if not configured
default api_base_url := "http://localhost:8080"

default api_timeout := "5s"

default environment := "development"

default basic_auth_token := ""
