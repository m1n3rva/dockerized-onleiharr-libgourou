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

# 5. Playwright is installed and importable (OIDC autologin prerequisite).
ONLEIHARR_VENV=$(pipx list --json 2>/dev/null | python3 -c "
import json, sys
data = json.load(sys.stdin)
for name, info in data.get('venvs', {}).items():
    if name == 'onleiharr':
        print('/root/.local/pipx/venvs/' + name)
        break
")
if [ -n "${ONLEIHARR_VENV:-}" ] && \
   "${ONLEIHARR_VENV}/bin/python" -c "import playwright" 2>/dev/null; then
    pass "playwright importable"
else
    fail "playwright import failed"
fi

# 6. Onleiharr external_auth module is present (OIDC autologin).
# In dev builds (ONLEIHARR_SOURCE contains git+): hard fail if missing.
# In stable builds: skip if absent (OIDC feature not yet released on PyPI).
_IS_DEV=false
if echo "${ONLEIHARR_SOURCE:-}" | grep -q '^git+'; then
  _IS_DEV=true
fi
if [ "$_IS_DEV" = "true" ]; then
  if [ -n "${ONLEIHARR_VENV:-}" ] && \
     "${ONLEIHARR_VENV}/bin/python" -c "import onleiharr.external_auth" 2>/dev/null; then
    pass "onleiharr.external_auth present"
  else
    fail "onleiharr.external_auth missing (dev build requires it)"
  fi
elif [ -n "${ONLEIHARR_VENV:-}" ] && \
     "${ONLEIHARR_VENV}/bin/python" -c "import onleiharr.external_auth" 2>/dev/null; then
  pass "onleiharr.external_auth present"
else
  echo "[SKIP] onleiharr.external_auth not present (OIDC feature not yet released)"
fi

# 7. Chromium browser binary is installed (OIDC autologin).
if [ -n "${PLAYWRIGHT_BROWSERS_PATH:-}" ] && \
   find "${PLAYWRIGHT_BROWSERS_PATH}" -path "*/chrome-linux64/chrome" -type f 2>/dev/null | head -1 | grep -q .; then
     pass "chromium browser present"
else
     fail "chromium browser missing"
fi

echo ""
echo "Results: ${PASSED} passed, ${FAILED} failed"

if [ "${FAILED}" -gt 0 ]; then
    echo "Smoke tests FAILED."
    exit 1
fi

echo "All smoke tests passed."
exit 0
