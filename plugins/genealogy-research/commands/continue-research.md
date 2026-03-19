---
name: continue-research
description: Continue existing genealogy research for a subject — skips intake, reads prior state, resumes from gaps
arguments:
  - name: name
    description: "Subject identifier (e.g., 'abraham-goldberg'). If omitted, lists available subjects."
    required: false
  - name: direction
    description: "Optional focus direction (e.g., 'maternal line', 'LEVY surname', 'parent-name searches')"
    required: false
---

# /continue-research — Resume Existing Research

You ARE the research-lead agent. Follow the instructions in the `research-lead` agent definition exactly, using the **"For Continuing Research"** path — NOT the new subject path.

**This is NOT a fresh start.** The subject already has research data. Your job is to pick up where the last session left off.

## Arguments

- `$ARGUMENTS.name` — subject identifier (required to proceed)
- `$ARGUMENTS.direction` — optional focus area for this session

## Step 1: Orient (no intake, no questions)

1. If no name provided, list available subjects:
   ```
   ls subjects/
   ```
   Ask the user to pick one, then proceed.

2. Read the subject's existing state — ALL of these:
   - `subjects/<name>/README.md` — master index, direct line, known gaps
   - `subjects/<name>/search_index.md` — every search already performed
   - `subjects/<name>/branches/` — list all branch files

3. Present a **brief status summary** to the user:
   - Persons researched so far (count)
   - Generations reached
   - Top 3-5 unresolved gaps (from README.md)
   - Any "Candidates Requiring Review" sections that need human input
   - Parent-name searches NOT yet done (parents known but `[parent]` search not in search_index.md)

4. If the user provided a `direction`, confirm you'll focus there. Otherwise, state which gaps you'll prioritize (following Research Priorities order) and ask for a quick go-ahead.

## Step 2: Authenticate

- Run `${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-login.sh`
- If researching Vienna/Lower Austria families, also authenticate to GenTeam.at

## Step 3: Execute (autonomous)

1. Create agent team: `TeamCreate("research-<subject-name>")`
2. Create tasks for the top research targets — prioritizing:
   - **Parent-name searches not yet done** — check search_index.md for `[parent]` entries; any known parent without one is a high-priority task
   - **Recursive expansion** — newly discovered parents from prior sessions that haven't been researched yet
   - **User's chosen direction** (if provided)
   - **Highest-priority gaps** from README.md (following Research Priorities order)
3. Enter the research loop from the research-lead agent definition
4. **Critical: avoid duplicate work** — do NOT re-search any surname/given/match-type/region combination already in search_index.md

## What Makes This Different From /research

| | `/research` | `/continue-research` |
|---|---|---|
| Intake questions | Yes — asks about the person, gathers context | No — reads existing README.md |
| Quick recon searches | Yes — discovers databases | No — databases already known |
| Research brief | Yes — presents and waits for confirmation | Brief status summary only |
| Subject folder | Creates if needed | Must already exist |
| search_index.md | Starts empty | Reads to avoid duplicate work |
| Team creation | Same | Same |
| Research loop | Same | Same |
