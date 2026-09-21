#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Smoke tests for dockerized-onleiharr-libgourou.
# Run inside the container to verify the image is functional.
# Usage: docker run --rm <image> /tests/smoke.sh

set -euo pipefail

PASSED=0
FAILED=0

pass() { echo "[PASS] $1"; PASSED=$((PASSED + 1)); }
fail() { echo "[FAIL] $1"; FAILED=$((FAILED + 1)); }

echo "Running smoke tests..."

# 1. onleiharr is installed and responds to --help
if onleiharr --help > /dev/null 2>&1; then
    pass "onleiharr --help succeeds"
else
    fail "onleiharr --help failed"
fi

# 2. onleiharr --version works
if VERSION=$(onleiharr --version 2>/dev/null); then
    pass "onleiharr --version outputs: ${VERSION}"
else
    fail "onleiharr --version failed"
fi

# 3. acsmdownloader (libgourou) is available
if acsmdownloader --help > /dev/null 2>&1; then
    pass "acsmdownloader --help succeeds"
else
    fail "acsmdownloader --help failed"
fi

# 4. adept_activate (libgourou utility) is available
if adept_activate --help > /dev/null 2>&1; then
    pass "adept_activate --help succeeds"
else
    fail "adept_activate --help failed"
fi

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed"

if [ "${FAILED}" -gt 0 ]; then
    echo "Smoke tests FAILED."
    exit 1
fi

echo "All smoke tests passed."
exit 0
