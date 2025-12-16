#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load environment variables from project root
set -a
source "$SCRIPT_DIR/.env"
set +a

# Change to dbt project directory
cd "$SCRIPT_DIR/dbt_project"

# Run dbt command with the local profiles.yml
DBT_PROFILES_DIR=. uv run dbt "$@"
