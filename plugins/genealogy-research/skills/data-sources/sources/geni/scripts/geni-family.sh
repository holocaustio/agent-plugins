#!/usr/bin/env bash
# Fetch immediate family for a Geni.com profile.
# Returns parents, children, spouses, and siblings.
# Outputs JSON to stdout.
#
# Usage: geni-family.sh PROFILE_ID
#
# Profile ID can be numeric (6000000000841549574) or prefixed (profile-6000000000841549574).

set -euo pipefail

TOKEN_FILE="/tmp/geni_token.txt"

if [[ -z "${GENI_TOKEN:-}" ]]; then
    if [[ -f "$TOKEN_FILE" ]]; then
        GENI_TOKEN=$(cat "$TOKEN_FILE")
    else
        echo "ERROR: No Geni token. Run: source geni-login.sh" >&2
        exit 1
    fi
fi

PROFILE_ID="${1:?Usage: geni-family.sh PROFILE_ID}"
# Strip "profile-" prefix if present
PROFILE_ID=$(echo "$PROFILE_ID" | sed 's/^profile-//')

echo "Fetching immediate family for: $PROFILE_ID" >&2

RESPONSE=$(curl -sS "https://www.geni.com/api/profile-${PROFILE_ID}/immediate-family?access_token=${GENI_TOKEN}")

# Output full response
echo "$RESPONSE"

# Summary to stderr
python3 -c "
import sys, json
d = json.load(sys.stdin)
nodes = d.get('nodes', {})
profiles = [k for k in nodes if k.startswith('profile-')]
unions = [k for k in nodes if k.startswith('union-')]
print(f'Family nodes: {len(profiles)} people, {len(unions)} unions', file=sys.stderr)
" <<< "$RESPONSE" 2>/dev/null || true

sleep 1  # Rate limit courtesy
