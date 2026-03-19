#!/usr/bin/env bash
# JewishGen Request Throttle
# Sources this file to get throttle_request() function.
# Enforces minimum delay between requests and tracks request count per session.
#
# Usage:
#   source "$(dirname "$0")/jg-throttle.sh"
#   throttle_request          # waits if needed, increments counter
#
# Config (env vars):
#   JG_MIN_DELAY=3       Minimum seconds between requests (default: 3)
#   JG_MAX_DELAY=6       Maximum seconds between requests (default: 6)
#   JG_MAX_REQUESTS=60   Max requests per session before warning (default: 60)

JG_THROTTLE_FILE="/tmp/jg_throttle_state"
JG_MIN_DELAY="${JG_MIN_DELAY:-3}"
JG_MAX_DELAY="${JG_MAX_DELAY:-6}"
JG_MAX_REQUESTS="${JG_MAX_REQUESTS:-60}"

_jg_random_delay() {
  # Random delay between MIN and MAX (inclusive)
  local range=$(( JG_MAX_DELAY - JG_MIN_DELAY + 1 ))
  local rand=$(( RANDOM % range + JG_MIN_DELAY ))
  echo "$rand"
}

throttle_request() {
  local now
  now=$(date +%s)

  # Read last request time and count
  local last_time=0
  local count=0
  if [[ -f "$JG_THROTTLE_FILE" ]]; then
    last_time=$(sed -n '1p' "$JG_THROTTLE_FILE" 2>/dev/null || echo 0)
    count=$(sed -n '2p' "$JG_THROTTLE_FILE" 2>/dev/null || echo 0)
  fi

  # Check request count
  count=$((count + 1))
  if [[ $count -gt $JG_MAX_REQUESTS ]]; then
    echo "WARNING: $count requests this session (limit: $JG_MAX_REQUESTS). Consider pausing to avoid bot detection." >&2
  fi

  # Calculate required delay
  local elapsed=$((now - last_time))
  local delay
  delay=$(_jg_random_delay)

  if [[ $elapsed -lt $delay && $last_time -gt 0 ]]; then
    local wait_time=$((delay - elapsed))
    echo "  [throttle] waiting ${wait_time}s before request #${count}..." >&2
    sleep "$wait_time"
  fi

  # Update state
  printf '%s\n%s\n' "$(date +%s)" "$count" > "$JG_THROTTLE_FILE"
}

# Reset counter (call after fresh login)
throttle_reset() {
  rm -f "$JG_THROTTLE_FILE"
}
