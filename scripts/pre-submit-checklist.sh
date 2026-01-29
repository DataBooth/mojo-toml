#!/usr/bin/env bash
# Thin wrapper around the Python pre-submission checklist.
#
# The actual logic now lives in scripts/pre_submit_checklist.py, which provides
# a more robust implementation than the previous Bash-heavy version.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

PYTHON_BIN="${PYTHON_BIN:-python3}"
if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    if command -v python >/dev/null 2>&1; then
        PYTHON_BIN=python
    else
        echo "Python 3 is required to run the pre-submit checklist" >&2
        exit 1
    fi
fi

"$PYTHON_BIN" "$SCRIPT_DIR/pre_submit_checklist.py" "$@"
