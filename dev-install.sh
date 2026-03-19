#!/usr/bin/env bash
# Install local plugin into Claude Code for dev testing.
# Re-run after changes to sync. Restart CC to pick up.
#
# Usage: ./dev-install.sh                    (install genealogy-research)
#        ./dev-install.sh --uninstall        (uninstall)

set -euo pipefail

MARKETPLACE="holocaustio"
PLUGIN="genealogy-research"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
UNINSTALL=false

if [[ "${1:-}" == "--uninstall" ]]; then
  UNINSTALL=true
fi

if [[ "$UNINSTALL" == true ]]; then
  echo "Uninstalling $PLUGIN..."
  claude plugin uninstall "$PLUGIN@$MARKETPLACE" 2>/dev/null || true
  claude plugin marketplace remove "$MARKETPLACE" 2>/dev/null || true
  echo "Done. Restart Claude Code to pick up the change."
  exit 0
fi

# Validate source exists
if [[ ! -d "$SCRIPT_DIR/plugins/$PLUGIN/.claude-plugin" ]]; then
  echo "Error: $SCRIPT_DIR/plugins/$PLUGIN/.claude-plugin not found" >&2
  exit 1
fi

echo "Installing $PLUGIN from local marketplace..."

# Register (or re-register) the local marketplace, then install the plugin
claude plugin marketplace remove "$MARKETPLACE" 2>/dev/null || true
claude plugin marketplace add "$SCRIPT_DIR"
claude plugin install "$PLUGIN@$MARKETPLACE" --scope user

echo "Done. Restart Claude Code to pick up the plugin."
