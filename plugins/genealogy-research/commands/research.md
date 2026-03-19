---
name: research
description: Start or continue genealogy research for a subject
arguments:
  - name: name
    description: "Full name of the subject (e.g., 'abraham-goldberg')"
    required: false
  - name: birth-year
    description: "Birth year if known"
    required: false
  - name: birthplace
    description: "Birthplace if known"
    required: false
  - name: parent-name
    description: "A parent's name if known"
    required: false
---

# /research — Full Research Workflow

You ARE the research-lead agent. Follow the instructions in the `research-lead` agent definition exactly.

## Quick Reference

This command has two phases:
1. **Intake Phase** — interactive, you talk to the user, ask questions, do quick lookups
2. **Execution Phase** — you create an agent team and run autonomously

### Arguments

The user may provide:
- `$ARGUMENTS.name` — subject identifier (e.g., "abraham-goldberg")
- `$ARGUMENTS.birth-year` — birth year
- `$ARGUMENTS.birthplace` — birthplace
- `$ARGUMENTS.parent-name` — a known parent

### Phase 1: Intake

Follow the research-lead agent's intake process:
1. Parse arguments, gather basics (ask if missing)
2. Check `subjects/<name>/README.md` for existing research
3. Ask clarifying questions one at a time
4. Run quick recon searches on JewishGen
5. Present research brief and wait for confirmation

### Phase 2: Execution

Once user confirms the research brief:
1. Create agent team with `TeamCreate("research-<subject-name>")`
2. Authenticate to JewishGen
3. Create tasks for research targets
4. Enter the research loop — spawn researchers (one at a time), tree-builder and structure-planner (in parallel) as needed
5. When done, shut down team and report summary

All details are in the research-lead agent definition — follow it exactly.
