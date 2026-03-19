---
name: tree
description: Regenerate tree.md and tree.json from research data
arguments:
  - name: subject-name
    description: "Subject folder name (e.g., 'abraham-goldberg')"
    required: false
---

# /tree — Regenerate Tree Outputs

Regenerate the human-readable `tree.md` and machine-readable `tree.json` files from the current research data.

## Step 1: Find Subject

If `$ARGUMENTS.subject-name` is provided, use it. Otherwise:
- Look in `subjects/` for available subjects
- If only one exists, use it
- If multiple exist, ask the user which one

## Step 2: Verify Data Exists

Check that the subject folder has research data:
- `subjects/<name>/README.md` must exist
- At least one of: `branches/*.md` files OR `family_tree.md`

If no research data exists, tell the user to run `/research` first.

## Step 3: Launch Tree Builder

Use the Task tool to spawn a `tree-builder` agent:

```
Subject folder: subjects/<name>/
Task: Read README.md and all branches/*.md files, then generate:
1. subjects/<name>/tree.md — human-readable family tree
2. subjects/<name>/tree.json — machine-readable structured data

Follow the formats defined in the research-methodology skill references:
- tree-md-format.md for tree.md
- tree-json-schema.md for tree.json
```

## Step 4: Report

When the tree-builder completes:
- Confirm both files were written
- Show a brief preview of the tree structure (first 20 lines of tree.md)
- Report the person count from tree.json
