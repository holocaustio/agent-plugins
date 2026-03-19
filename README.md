# Holocaust IO — Agent Plugins

Claude Code plugins for Holocaust research and Jewish genealogy.

## Available Plugins

### genealogy-research

Systematic Jewish genealogy research using [JewishGen](https://www.jewishgen.org) and 10+ databases. Start from one person, trace ancestry as far as records allow, with full source tracking and evidence chains.

- Searches 80+ JewishGen sub-databases (births, marriages, deaths, Holocaust records, burial registries, emigration)
- Traces ancestry upward — parents, grandparents, great-grandparents — as deep as records go
- Records all siblings of each direct ancestor
- Tracks every fact to its source with retraceable search parameters
- Builds evidence chains proving each relationship
- Produces both human-readable and machine-readable family tree outputs
- Runs autonomously — gathers input upfront, then researches without interruptions

## Installation

```bash
# 1. Add the marketplace (one-time)
/plugin marketplace add holocaustio/agent-plugins

# 2. Install the plugin
/plugin install genealogy-research@holocaustio
```

## Requirements

- A [JewishGen](https://www.jewishgen.org) account (free registration)
- Set credentials: `export JG_USER="your@email.com"` and `export JG_PASS="yourpassword"`
- For non-JewishGen archive sites: `npm install && npx playwright install chromium` inside the plugin directory

## License

MIT
