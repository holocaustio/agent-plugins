#!/usr/bin/env bash
# JewishGen Auth0 Login
# Reads $JG_USER and $JG_PASS from environment
# Creates/refreshes cookie jar at /tmp/jg_cookies.txt
# Exit 0 on success, 1 on failure

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/jg-throttle.sh"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
COOKIE_JAR="/tmp/jg_cookies.txt"

if [[ -z "${JG_USER:-}" || -z "${JG_PASS:-}" ]]; then
  echo "ERROR: Set JG_USER and JG_PASS environment variables" >&2
  exit 1
fi

# Reset throttle counter for fresh session
throttle_reset

# Step 1: Clear old cookies and fetch Auth0 login page
rm -f "$COOKIE_JAR"
curl -sS -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -H "User-Agent: $UA" \
  -o /tmp/jg_auth0_page.html \
  -w '%{url_effective}' \
  "https://www.jewishgen.org/Auth0/login.php" 2>/dev/null

# Step 2: Extract state token
LC_ALL=C STATE=$(sed -n 's/.*name="state" value="\([^"]*\)".*/\1/p' /tmp/jg_auth0_page.html | head -1)

if [[ -z "$STATE" ]]; then
  echo "ERROR: Could not extract Auth0 state token" >&2
  exit 1
fi

# Step 3: POST credentials to Auth0
RESUME_URL=$(curl -sS -D /tmp/jg_login_headers.txt \
  -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -H "User-Agent: $UA" \
  -X POST "https://login.jewishgen.org/u/login?state=$STATE" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Origin: https://login.jewishgen.org" \
  --data-urlencode "state=$STATE" \
  --data-urlencode "username=$JG_USER" \
  --data-urlencode "password=$JG_PASS" \
  --data-urlencode "action=default" \
  -w '%{redirect_url}' -o /dev/null 2>/dev/null)

if [[ -z "$RESUME_URL" ]]; then
  echo "ERROR: Login failed — no redirect URL (check credentials)" >&2
  exit 1
fi

# Step 4: Follow redirect chain to complete login
curl -sS -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" \
  -H "User-Agent: $UA" \
  "$RESUME_URL" -o /dev/null 2>/dev/null

# Verify
if grep -q jgcure "$COOKIE_JAR" 2>/dev/null; then
  echo "OK: Logged in as $JG_USER"
  exit 0
else
  echo "ERROR: Login flow completed but jgcure cookie not found" >&2
  exit 1
fi
