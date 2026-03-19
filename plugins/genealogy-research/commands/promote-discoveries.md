---
name: promote-discoveries
description: Merge local discoveries into the plugin's built-in reference files (maintainer only)
---

# /promote-discoveries — Merge Local Discoveries Into Plugin

This command is for the **plugin maintainer**. It reads `.discoveries/` files from the project root and merges their contents into the plugin's built-in reference files at `${CLAUDE_PLUGIN_ROOT}/skills/`.

Regular users accumulate discoveries locally — this command promotes them to the shared plugin.

## Step 1: Check for Discoveries

Look for `.discoveries/` in the project root. If it doesn't exist or is empty, report "No discoveries to promote" and stop.

List all files found and their line counts.

## Step 2: Review Each Discovery File

For each file in `.discoveries/`, read its contents and present a summary:

### database-catalog.md
- Show each new database entry (name, df, notes, provenance)
- For each entry, check if it already exists in `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/references/database-catalog.md`
- Flag duplicates and skip them
- Ask: "Promote these N new databases to the built-in catalog?"

### html-patterns.md
- Show each new column pattern entry
- Check for duplicates in built-in `html-parsing.md`
- Ask: "Promote these N new patterns?"

### url-parameters.md
- Show new region codes or parameters
- Check for duplicates in built-in `url-parameters.md`
- Ask: "Promote these N new parameters?"

### deduction-techniques.md
- Show new techniques
- Check for duplicates in built-in `deduction-techniques.md`
- Ask: "Promote these N new techniques?"

### gotchas.md
- Show new gotchas
- Check for duplicates in built-in SKILL.md
- Ask: "Promote these N new gotchas?"

## Step 3: Merge

For each approved set:

1. **database-catalog.md** → Append new rows to the appropriate regional section in the built-in catalog (or to "Other" if region is unclear). Remove the provenance column (it was for tracking, not for the permanent catalog).

2. **html-patterns.md** → Append entries to the "Database-Specific Column Patterns" section in the built-in `html-parsing.md`.

3. **url-parameters.md** → Append new region codes to the region table, new params to the relevant section in the built-in `url-parameters.md`.

4. **deduction-techniques.md** → Append to the built-in `deduction-techniques.md` in the research-methodology skill.

5. **gotchas.md** → Append to the Gotchas list in the built-in `SKILL.md`.

## Step 4: Clean Up

After merging, clear the promoted entries from `.discoveries/` files:
- Replace file contents with just the header (keep the file structure, clear the data)
- Report how many entries were promoted per file

## Step 5: Suggest Commit

Tell the user:
> "Promoted N discoveries into the plugin's built-in references. You should commit the changes to the plugin repository so other users benefit."
