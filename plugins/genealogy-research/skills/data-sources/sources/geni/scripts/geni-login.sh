#!/usr/bin/env bash
# Geni.com OAuth2 login.
# Supports two flows:
#   1. Authorization code (user-level, full API access) — pass the code as $1
#   2. Client credentials (app-level, limited) — no arguments
#
# Usage:
#   source geni-login.sh              # client credentials (limited)
#   source geni-login.sh AUTH_CODE    # exchange authorization code for user token
#   source geni-login.sh --authorize  # print the authorize URL to open in browser
#
# Env vars: GENI_CLIENT_ID, GENI_CLIENT_SECRET
# Output: sets $GENI_TOKEN, writes to /tmp/geni_token.txt

set -euo pipefail

TOKEN_FILE="/tmp/geni_token.txt"
REDIRECT_URI="http://localhost:8080/callback"

# --authorize: just print the URL
if [[ "${1:-}" == "--authorize" ]]; then
    echo "Open this URL in your browser, authorize, then copy the code:" >&2
    echo "https://www.geni.com/platform/oauth/authorize?client_id=${GENI_CLIENT_ID}&response_type=code&redirect_uri=${REDIRECT_URI}" >&2
    echo "" >&2
    echo "Then run:  source geni-login.sh YOUR_CODE" >&2
    return 0 2>/dev/null || exit 0
fi

# Check if existing token is still valid (less than 50 min old — tokens expire in 1h)
if [[ -f "$TOKEN_FILE" ]] && [[ -z "${1:-}" ]]; then
    token_age=$(( $(date +%s) - $(stat -f %m "$TOKEN_FILE" 2>/dev/null || stat -c %Y "$TOKEN_FILE" 2>/dev/null) ))
    if (( token_age < 3000 )); then
        GENI_TOKEN=$(cat "$TOKEN_FILE")
        export GENI_TOKEN
        echo "Reusing existing Geni token (age: $((token_age / 60))m)" >&2
        return 0 2>/dev/null || exit 0
    fi
fi

if [[ -z "${GENI_CLIENT_ID:-}" ]] || [[ -z "${GENI_CLIENT_SECRET:-}" ]]; then
    echo "ERROR: GENI_CLIENT_ID and GENI_CLIENT_SECRET must be set" >&2
    return 1 2>/dev/null || exit 1
fi

# Check for refresh token file
REFRESH_FILE="/tmp/geni_refresh_token.txt"

if [[ -n "${1:-}" ]]; then
    # Authorization code flow — exchange code for token
    AUTH_CODE="$1"
    echo "Exchanging authorization code for Geni token..." >&2
    RESPONSE=$(curl -sS "https://www.geni.com/platform/oauth/request_token?\
client_id=${GENI_CLIENT_ID}&\
client_secret=${GENI_CLIENT_SECRET}&\
grant_type=authorization_code&\
code=${AUTH_CODE}&\
redirect_uri=${REDIRECT_URI}")

elif [[ -f "$REFRESH_FILE" ]]; then
    # Refresh token flow
    REFRESH_TOKEN=$(cat "$REFRESH_FILE")
    echo "Refreshing Geni token..." >&2
    RESPONSE=$(curl -sS "https://www.geni.com/platform/oauth/request_token?\
client_id=${GENI_CLIENT_ID}&\
client_secret=${GENI_CLIENT_SECRET}&\
grant_type=refresh_token&\
refresh_token=${REFRESH_TOKEN}")

else
    # Client credentials flow (limited access)
    echo "Requesting Geni app token (limited access)..." >&2
    echo "For full access, run: source geni-login.sh --authorize" >&2
    RESPONSE=$(curl -sS "https://www.geni.com/platform/oauth/request_token?\
client_id=${GENI_CLIENT_ID}&\
client_secret=${GENI_CLIENT_SECRET}&\
grant_type=client_credentials")
fi

# Parse response
if echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'access_token' in d else 1)" 2>/dev/null; then
    GENI_TOKEN=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
    export GENI_TOKEN
    echo "$GENI_TOKEN" > "$TOKEN_FILE"

    # Save refresh token if present
    REFRESH=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('refresh_token',''))" 2>/dev/null)
    if [[ -n "$REFRESH" ]]; then
        echo "$REFRESH" > "$REFRESH_FILE"
    fi

    EXPIRES=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('expires_in','?'))" 2>/dev/null)
    echo "Geni token acquired (expires in ${EXPIRES}s). Saved to $TOKEN_FILE" >&2
else
    echo "ERROR: Failed to get Geni token. Response:" >&2
    echo "$RESPONSE" >&2
    return 1 2>/dev/null || exit 1
fi
