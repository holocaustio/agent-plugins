# HTML Parsing Patterns for JewishGen Results

**Important:** Always use `LC_ALL=C` when processing response HTML — it may contain non-UTF8 bytes.

## Unified Search Results

Response from `jgform.php` contains a summary of which databases matched.

### Total Match Count

```
<H2>N total matches found</H2>
```

Extract with:
```bash
LC_ALL=C grep -oP '\d[\d,]+ total matches found' response.html | head -1
```

### Sub-database Entries

Each matching database appears as a form with a hidden `df` field and a submit button:

```html
<td><a href="...">Database Name</a></td>
...
<input name='df' value='DATABASE_ID' type='hidden'>
...
<input type='submit' value='List N records'>
```

Extract database ID, name, and count:
```bash
LC_ALL=C grep -oP "name='df' value='[^']+'" response.html
LC_ALL=C grep -oP "value='List \d+ records'" response.html
```

### Full Parsing Pipeline

The `jg-parse-unified.sh` script extracts all three fields per database into tab-separated output:
```
df_value\tdatabase_name\trecord_count
```

## Sub-database Detail Results

Response from `jgdetail_2.php` contains actual records.

### Match Count

```
N matching records found
```

Extract with:
```bash
LC_ALL=C grep -oP '\d+ matching records found' response.html
```

### Record Table Structure

Records are in a `<TABLE>` element, typically with `BGCOLOR=#E8E1D1`:

```html
<TABLE ... BGCOLOR=#E8E1D1>
  <THEAD>
    <TR><TH>Column1</TH><TH>Column2</TH>...</TR>
  </THEAD>
  <TBODY>
    <TR><TD>value1</TD><TD>value2</TD>...</TR>
    ...
  </TBODY>
</TABLE>
```

### Column Headers

Headers vary by database type:

| Database Type | Typical Columns |
|---------------|----------------|
| Births | Name, Date, Father, Mother, Town |
| Deaths | Name, Date, Age, Place, Burial |
| Marriages | Groom, Bride, Date, Place, Parents |
| Holocaust | Name, Birth Date, Residence, Fate, Source |
| Burial | Name, Date, Cemetery, Section/Row/Plot |

### Extracting Records

Strip HTML tags to get plain text fields:
```bash
# Extract all TD contents from a row
LC_ALL=C sed -n 's/<TD[^>]*>\([^<]*\)<\/TD>/\1\t/gp' response.html

# More robust: extract table rows
LC_ALL=C grep -oP '<TR[^>]*>.*?</TR>' response.html | \
  sed 's/<[^>]*>//g; s/&nbsp;/ /g; s/&amp;/\&/g'
```

### Pagination Detection

When more records exist beyond the current page:
```html
<input type='submit' value='Next N records'>
```

Or a link with `recstart=N` parameter.

## Common HTML Entities

| Entity | Character |
|--------|-----------|
| `&nbsp;` | Space |
| `&amp;` | & |
| `&ouml;` | o with umlaut |
| `&uuml;` | u with umlaut |
| `&#246;` | o with umlaut (numeric) |

## Database-Specific Column Patterns

This section contains known non-standard column layouts. Agents write NEW discoveries to `.discoveries/html-patterns.md` in the project root (this file is read-only).

<!-- Promoted entries from .discoveries/ go here -->

## Tips

1. **Don't parse with regex alone** for complex extraction — consider piping through `sed` or `awk` for multi-step processing
2. **Watch for multi-line records** — some cells span lines
3. **Empty cells** may appear as `<TD>&nbsp;</TD>` or `<TD></TD>`
4. **Links in cells** — some fields contain `<a href>` links (e.g., town names link to gazeteer)
5. **Record detail links** — some records have a "Details" link for expanded view
