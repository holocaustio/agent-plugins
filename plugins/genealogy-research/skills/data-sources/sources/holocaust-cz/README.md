# Holocaust.cz — Terezín Initiative Institute

**No authentication required.** HTML form-based search, parse with grep/sed.

## Search endpoint

POST to `https://www.holocaust.cz/en/database-of-victims/`

```bash
# By surname
curl -sS "https://www.holocaust.cz/en/database-of-victims/" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -d "searchSurname=SURNAME"

# By surname + first name
curl -sS "https://www.holocaust.cz/en/database-of-victims/" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -d "searchSurname=SURNAME&searchFirstname=GIVEN"

# Full search
curl -sS "https://www.holocaust.cz/en/database-of-victims/" \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -d "searchSurname=SURNAME&searchFirstname=GIVEN&searchPlaceBirth=PLACE&searchDateBirthYear=YEAR&searchPlaceLast=LAST_RESIDENCE"
```

### Search parameters
| Parameter | Description |
|-----------|-------------|
| `searchFirstname` | First name |
| `searchSurname` | Surname |
| `searchPlaceLast` | Last residence before deportation |
| `searchPlaceBirth` | Birth place |
| `searchDateBirthDay` | Birth day (1-31) |
| `searchDateBirthMonth` | Birth month (1-12) |
| `searchDateBirthYear` | Birth year |
| `searchTransport` | Transport code (e.g., `Ac`, `IV/12`) |

## Parsing results

Extract victim URLs from search response:
```bash
curl -sS "https://www.holocaust.cz/en/database-of-victims/" \
  -H "User-Agent: Mozilla/5.0" \
  -d "searchSurname=SURNAME" | \
  LC_ALL=C grep -o 'href="https://www.holocaust.cz/en/database-of-victims/victim/[^"]*"' | \
  sed 's/href="//;s/"$//'
```

## Detail pages

URL pattern: `https://www.holocaust.cz/en/database-of-victims/victim/{id}-{name-slug}/`

Fields on detail pages:
- **Name**
- **Birth date** (DD.MM.YYYY)
- **Last residence before deportation** (full address with district)
- **Transport details** — code, number, date, route (origin → destination)
- **Multiple transports** — full chain (e.g., Vienna→Terezín, Terezín→Auschwitz)
- **Fate** — Murdered / Survived
- **Transport statistics** — total deported, murdered, survived per transport

## Czech feminine suffixes

Czech records add `-ová` to female surnames. Always search BOTH:
- `GOLDBERG` AND `GOLDBERGOVA`
- `LEVY` AND `LEVYOVA`

## Source citation format
```
[S: database="Holocaust.cz" | source="holocaust-cz" | search="searchSurname=SURNAME&searchFirstname=GIVEN" | record="SURNAME, Given | b.DATE | last: ADDRESS | transport: CODE no.NUM | fate: murdered"]
```

## What you get that JewishGen doesn't have
- **Czech transport codes** — detailed route info (Ac, Eq, IV/12, etc.)
- **Last address with district** — "Wien 2, Grosse Mohrengasse 34/14"
- **Transport chain** — full sequence of deportations, not just final destination
- **Transport statistics** — survival rates per transport
- **Linked documents** — some victims have digitized original documents from Jewish Museum Prague
