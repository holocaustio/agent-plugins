# File Writing Strategy

**Never use a single Write call for files over ~150 lines.** Large Write calls cause infinite tool-call loops. Instead, build files incrementally:

## General Pattern
1. **Write a skeleton** — headers, empty sections, minimal boilerplate (<100 lines)
2. **Fill with Edit calls** — add content section by section
3. **Prefer Edit over Write** — even for new files, scaffold first then populate

## Branch Files (up to 500 lines)
```
Step 1: Write skeleton with ## headers for each person (empty sections)
Step 2: Edit to fill in each person's details one at a time
```

## tree.md
```
Step 1: Write header + Direct Line section only
Step 2: Edit to append each Generation section one at a time
Step 3: Edit to append Holocaust/Emigrants tables at the end
```

## tree.json
```
Step 1: Write skeleton: { "meta": {...}, "sources": {}, "persons": {}, "claims": {}, "direct_line": [], ... }
Step 2: Edit to add sources in batches (5-10 at a time)
Step 3: Edit to add persons in batches (3-5 at a time)
Step 4: Edit to add claims in batches
Step 5: Edit to fill direct_line, holocaust_victims, emigrants
```

## search_index.md
- Start with section headers, append rows via Edit as searches complete
- Never rewrite the whole file — always append to existing tables

## Delegating to Agents
When an agent is responsible for writing a large file (e.g., tree-builder writing tree.json), the agent itself must follow these incremental patterns. The calling agent should remind it: **"Build the file incrementally — skeleton first, then Edit calls to fill sections. Never write more than 150 lines in a single Write call."**
