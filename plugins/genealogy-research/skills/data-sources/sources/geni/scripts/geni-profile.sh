#!/usr/bin/env bash
# Fetch one or more Geni.com profiles.
# Outputs JSON to stdout.
#
# Usage:
#   geni-profile.sh PROFILE_ID
#   geni-profile.sh PROFILE_ID1 PROFILE_ID2 PROFILE_ID3
#
# Profile IDs can be numeric (6000000000841549574) or prefixed (profile-6000000000841549574).

set -euo pipefail

TOKEN_FILE="/tmp/geni_token.txt"
FIELDS="first_name,last_name,maiden_name,birth,death,burial,gender,nicknames,occupation,cause_of_death,unions,is_alive,public,big_tree,profile_url"

if [[ -z "${GENI_TOKEN:-}" ]]; then
    if [[ -f "$TOKEN_FILE" ]]; then
        GENI_TOKEN=$(cat "$TOKEN_FILE")
    else
        echo "ERROR: No Geni token. Run: source geni-login.sh" >&2
        exit 1
    fi
fi

if [[ $# -eq 0 ]]; then
    echo "Usage: geni-profile.sh PROFILE_ID [PROFILE_ID...]" >&2
    exit 1
fi

# Normalize IDs — strip "profile-" prefix if present
normalize_id() {
    echo "$1" | sed 's/^profile-//'
}

FIRST_ID=$(normalize_id "$1")

if [[ $# -eq 1 ]]; then
    # Single profile
    echo "Fetching Geni profile: $FIRST_ID" >&2
    curl -sS "https://www.geni.com/api/profile-${FIRST_ID}?fields=${FIELDS}&access_token=${GENI_TOKEN}"
else
    # Multiple profiles — batch via ids parameter
    IDS=""
    for id in "$@"; do
        nid=$(normalize_id "$id")
        if [[ -n "$IDS" ]]; then
            IDS="${IDS},${nid}"
        else
            IDS="$nid"
        fi
    done
    echo "Fetching ${#} Geni profiles" >&2
    curl -sS "https://www.geni.com/api/profile-${FIRST_ID}?ids=${IDS}&fields=${FIELDS}&access_token=${GENI_TOKEN}"
fi

sleep 1  # Rate limit courtesy
