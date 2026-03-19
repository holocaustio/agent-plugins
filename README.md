# Holocaust IO — Claude Code Plugin Marketplace

A Claude Code plugin marketplace for Holocaust research and Jewish genealogy.

## Installation

```bash
# Add the marketplace (one-time)
/plugin marketplace add holocaustio/agent-plugins

# Then install any plugin from the list below
/plugin install <plugin-name>@holocaustio
```

## Plugins

| Plugin | Description |
|--------|-------------|
| [genealogy-research](plugins/genealogy-research/) | Systematic Jewish genealogy research — trace ancestry across 10+ databases with full source tracking and evidence chains |

## Development

To test a plugin locally without pushing to GitHub:

```bash
# Install local copy into Claude Code
./dev-install.sh [plugin-name]

# After making changes, re-run to sync, then restart Claude Code
./dev-install.sh [plugin-name]

# Remove dev install
./dev-install.sh --uninstall [plugin-name]
```

Defaults to `genealogy-research` if no plugin name is given.

## License

MIT
