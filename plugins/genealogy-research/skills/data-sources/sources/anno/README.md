# ANNO — Austrian National Library Newspapers

Searches digitized Austrian newspapers (1700s–1940s) from the Austrian National Library. Finds birth/death/marriage announcements, obituaries, business notices, legal mentions.

**No authentication required.** Uses headless browser (Playwright).

## Script

`${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/anno/scripts/anno-search.sh`

```bash
anno-search.sh QUERY [FROM_YEAR] [TO_YEAR]
```

| Arg | Default | Purpose |
|-----|---------|---------|
| QUERY | required | Search term — use German spelling |
| FROM_YEAR | 1880 | Start year |
| TO_YEAR | 1940 | End year |

**Output:** Tab-separated: `NEWSPAPER_AND_DATE\tPAGES\tHITS\tLINK`

## Tips

- Search in German — use period spelling ("Goldberg" not "Golberg")
- Best coverage: 1880s–1930s
- Most useful papers: Wiener Zeitung, Neue Freie Presse, Die Neuzeit (Jewish)
- For common names, add a town or occupation to the query

## Source citation format

```
[S: database="ANNO" | source="anno" | search="QUERY FROM_YEAR-TO_YEAR" | record="NEWSPAPER, DATE | page N | summary"]
```
