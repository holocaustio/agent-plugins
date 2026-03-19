# tree.md — Human-Readable Tree Format

## Purpose

A clean, indented tree showing the direct line and siblings at each generation. Easy to scan visually. No research notes or source citations — those live in the branch files.

## Template

```markdown
# [TARGET PERSON]'s Family Tree

## Direct Line
TARGET PERSON
  └── Parent A ∞ Parent B
        └── Grandparent A1 ∞ Grandparent A2
              └── Great-Grandparent A1a ∞ Great-Grandparent A1b
                    └── ...

## Generation 1: Parents
### Parent A (birth–death) ∞ Parent B (birth–death)
- Marriage: date, place
- Children:
  1. **TARGET PERSON** (b. date, place) ← direct line
  2. Sibling (b. date – d. date) ∞ Spouse
  3. Sibling (b. date – d. date) — fate unknown

## Generation 2: Grandparents (Paternal)
### Grandparent A1 (birth–death) ∞ Grandparent A2 (birth–death)
- Marriage: date, place
- Children:
  1. **Parent A** ← direct line
  2. Uncle/Aunt (b. date – d. date) ∞ Spouse
  3. Uncle/Aunt (b. date – d. date) — murdered in Holocaust

## Generation 2: Grandparents (Maternal)
### Grandparent B1 (birth–death) ∞ Grandparent B2 (birth–death)
- Marriage: date, place
- Children:
  1. **Parent B** ← direct line
  2. Uncle/Aunt (b. date – d. date) ∞ Spouse

## Generation 3: Great-Grandparents
...

## Holocaust Victims
| Name | Birth | Last Address | Deported | Destination | Died |
|------|-------|-------------|----------|-------------|------|
| ... | ... | ... | ... | ... | ... |

## Emigrants
| Name | Destination | Approximate Date |
|------|------------|-----------------|
| ... | ... | ... |
```

## Formatting Rules

1. **Direct line ancestors are bolded** — `**Name**`
2. **Each generation gets its own section** — with `## Generation N` header
3. **Paternal and maternal sides are separate** within each generation
4. **Children listed as numbered list** — direct line marked with `← direct line`
5. **Marriage indicated with ∞** — `Parent A ∞ Parent B`
6. **Dates formatted as** `b. YYYY` or `YYYY-MM-DD` — `d. YYYY` for death
7. **Unknown dates** — use `~YYYY` for approximate, `?` for unknown
8. **Holocaust fates noted inline** — "murdered in Holocaust" or "deported to Auschwitz"
9. **No source citations** — tree.md is a clean output; sources are in branch files
10. **Holocaust victims table** — combined at the end for quick reference
11. **Emigrants table** — combined at the end

## Lifecycle

tree.md is a **living document** updated throughout research, not a final output.

### Initialization (by lead agent, before research begins)
Write the header + `## Direct Line` with just the target person (< 30 lines).

### Continuous Updates (by each branch researcher, after completing a person)
1. Read the current tree.md
2. Edit to update the `## Direct Line` section if a new ancestor was found
3. Edit to add or extend the relevant `## Generation N` section with the new person + siblings
4. Edit to add rows to Holocaust/Emigrants tables if applicable

### Full Rebuild (via `/tree` command, if files get out of sync)
1. Read README.md + all branch files
2. Write header + Direct Line section (< 50 lines)
3. Edit to append each Generation section one at a time
4. Edit to append Holocaust/Emigrants tables

**Never write the entire tree.md in a single Write call** — it will exceed tool limits and cause loops. Always use Edit to extend existing content.
