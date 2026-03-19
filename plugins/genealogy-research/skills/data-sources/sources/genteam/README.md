# GenTeam.at — Austrian Genealogy Databases

**Requires login.** Credentials: `GT_USERNAME` / `GT_PASSWORD` env vars. Cookie-based session with CSRF tokens.

## Authentication

```bash
# Step 1: Get CSRF token
LOGIN_PAGE=$(curl -sS -c /tmp/genteam_cookies.txt \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  "https://www.genteam.at/en/")
CSRF_TOKEN=$(echo "$LOGIN_PAGE" | LC_ALL=C grep -o 'name="[a-f0-9]\{32\}" value="1"' | head -1 | LC_ALL=C grep -o '[a-f0-9]\{32\}')

# Step 2: Login
curl -sS -L -c /tmp/genteam_cookies.txt -b /tmp/genteam_cookies.txt \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -X POST "https://www.genteam.at/en/" \
  -d "username=${GT_USERNAME}&password=${GT_PASSWORD}&remember=yes&option=com_users&task=user.login&return=&${CSRF_TOKEN}=1"

# Verify: response should be >>1000 bytes and contain "logout"
```

Session expires after ~15-20 minutes. Refresh CSRF token before each search batch.

## Search endpoint

POST to `https://www.genteam.at/en/?option=com_db`

**Before searching**, get a fresh CSRF token:
```bash
PAGE=$(curl -sS -b /tmp/genteam_cookies.txt \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  "https://www.genteam.at/en/?option=com_db")
CSRF_TOKEN=$(echo "$PAGE" | LC_ALL=C grep -o 'name="[a-f0-9]\{32\}" value="1"' | head -1 | LC_ALL=C grep -o '[a-f0-9]\{32\}')
```

### Search a database
```bash
curl -sS -b /tmp/genteam_cookies.txt \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -H "X-Requested-With: XMLHttpRequest" \
  -X POST "https://www.genteam.at/en/?option=com_db" \
  -d "task=dbsearch&format=json&init=1&db=DB_NUMBER&opt=2&name=SURNAME&vname=GIVEN&jfrom=YEAR_FROM&jto=YEAR_TO&code=&geschlecht=&krland=&searchext1=&searchext2=&draw=1&start=0&length=25&${CSRF_TOKEN}=1"
```

### Parameters
| Param | Description | Values |
|-------|-------------|--------|
| `db` | Database number | See table below |
| `opt` | Match type | `1`=Contains, `2`=Starts with, `3`=Exact |
| `name` | Surname (min 3 chars) | |
| `vname` | Given name (optional) | |
| `jfrom` | Year from | e.g., `1850` |
| `jto` | Year to | e.g., `1920` |
| `start` | Pagination offset | `0`, `25`, `50`... |
| `length` | Page size | `10`, `25`, `50`, `100` |
| `init` | First search | `1` first time, `0` for pagination |
| `draw` | DataTables counter | Increment per request |

### Get record details
```bash
curl -sS -b /tmp/genteam_cookies.txt \
  -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  -H "X-Requested-With: XMLHttpRequest" \
  -X POST "https://www.genteam.at/en/?option=com_db" \
  -d "task=details&format=json&db=DB_NUMBER&name=SURNAME&vname=GIVEN&searchext1=&searchext2=&no=RECORD_ID&hs=HASH&${CSRF_TOKEN}=1"
```

## Key Jewish databases

### Tier 1 — Vital records
| DB# | Name | Coverage |
|-----|------|----------|
| **53** | Jüdische Matriken | Vienna + Lower Austria (St. Pölten, Baden, Mödling), 1826-1938 |
| **15** | Jüdische Indices | Moravia/Bohemia, 1730s-1944 |

### Tier 2 — Community records
| DB# | Name | Coverage |
|-----|------|----------|
| **7** | IKG-Austritte 1868-1914 | ~18,000 resignations from Vienna Jewish community |
| **55** | IKG Austritte 1915-1945 | Later resignations |
| **8** | Konvertiten in Wien | ~18,000 Jewish converts, 1782-1914 |

### Tier 3 — Cemeteries
| DB# | Name | Coverage |
|-----|------|----------|
| **37** | Jüdische Grabsteine | ~10,000 gravestone photos — Vienna + St. Pölten + Czech |
| **11** | Israelitische Friedhöfe | Vienna Jewish cemeteries |
| **36** | Israelitischer Friedhof Währing | Historic Währing cemetery |
| **17** | NFP Sterbeanzeigen | Neue Freie Presse obituaries, 1864-1938 |

### Tier 4 — Holocaust era
| DB# | Name | Coverage |
|-----|------|----------|
| **64** | Recht als Unrecht | Nazi property confiscation records, 1938-1945 |

## Response format
```json
{
  "draw": 1,
  "recordsTotal": 0,
  "recordsFiltered": 370,
  "data": [
    ["record_id", "surname", "given_name", "field3", ...],
  ]
}
```

Column positions vary by database. Parse by index.

## Source citation format
```
[S: database="GenTeam: Jüdische Matriken" | source="genteam" | db=53 | search="name=SURNAME&vname=GIVEN&opt=2" | record="SURNAME, Given | DATE | PLACE | Father: X | Mother: Y"]
```

## Rate limiting
- Terms prohibit automation — use 5-10 second delays between requests
- "Too many queries" error → back off
- Session expires → re-login and get fresh CSRF token

## What you get that JewishGen doesn't have
- **St. Pölten Jewish vital records** (DB 53) — births, marriages, deaths with parent names
- **Gravestone photos** (DB 37) — includes St. Pölten cemetery
- **NFP obituaries** (DB 17) — Neue Freie Presse death notices
- **Nazi property confiscation** (DB 64) — 1938 records
- **IKG community records** (DB 7/55) — who left the community and when
- **Converts** (DB 8) — who converted, from what religion, when
