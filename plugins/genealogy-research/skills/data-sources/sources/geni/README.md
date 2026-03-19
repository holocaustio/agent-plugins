# Geni.com — World Family Tree

**Authentication required.** OAuth2 client credentials. JSON API, no cookies needed.

## Value

Collaborative world family tree with 200M+ profiles. Other researchers may have already built out branches of your families. Instantly find existing tree work, get family connections without re-doing research.

**What you get that other sources don't have:**
- **Pre-built family trees** — other researchers have already connected generations
- **Immediate family traversal** — parents, children, siblings, spouses in one call
- **Ancestor chains** — up to 20 generations in a single request
- **Living people** — shows "Private" but confirms existence and connections
- **Cross-researcher collaboration** — find who else is researching your families

## Auth Setup

Credentials stored in env vars `GENI_CLIENT_ID` and `GENI_CLIENT_SECRET`.

**Important:** Client credentials (app-level) tokens have very limited access — search returns 404 and rate limit is 1 req/10s. You need a **user-authorized token** for full API access (search, profiles, family traversal).

### Step 1: Get a user token (one-time, in browser)

```bash
# Print the authorize URL
source ${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/geni/scripts/geni-login.sh --authorize
```

Open the URL in your browser, log in to Geni, authorize the app. Copy the authorization code.

### Step 2: Exchange the code

```bash
source ${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/geni/scripts/geni-login.sh YOUR_CODE_HERE
```

This sets `$GENI_TOKEN` (valid ~1h) and saves a refresh token to `/tmp/geni_refresh_token.txt`. Subsequent calls auto-refresh.

### Subsequent logins (auto-refresh)

```bash
source ${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/geni/scripts/geni-login.sh
```

If a refresh token exists and the access token is expired, it refreshes automatically. If the token is still valid (<50 min old), it reuses it.

### Known issues
- Geni website is behind Incapsula/Imperva WAF (owned by MyHeritage). The authorize page may be blocked if your IP was flagged by bot detection.
- The API token endpoint (`/platform/oauth/request_token`) is NOT behind Incapsula — curl works fine for token exchange/refresh.
- If blocked, wait a few hours or try from a different network.

## Search: GET /api/profile/search

```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/geni/scripts/geni-search.sh "SURNAME" ["GIVEN"]
```

**Limitation**: API only supports `names` parameter. No filtering by birth year/place in the API — filter client-side from results.

### Raw curl
```bash
curl -sS "https://www.geni.com/api/profile/search?names=Leopold+Plaschkes&access_token=$GENI_TOKEN"
```

### Response format
```json
{
  "results": [
    {
      "id": "profile-6000000000841549574",
      "first_name": "Hugo",
      "last_name": "Marek",
      "birth": {"date": {"year": 1891}, "location": {"city": "Vienna"}},
      "death": {"date": {"year": 1956}},
      "gender": "male",
      "profile_url": "https://www.geni.com/people/Hugo-Marek/...",
      "public": true
    }
  ],
  "page": 1,
  "next_page": "https://www.geni.com/api/profile/search?names=Plaschkes&page=2"
}
```

### Pagination
Follow `next_page` URL until it's absent. Each page returns up to 10 results.

## Profile: GET /api/profile-{ID}

```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/geni/scripts/geni-profile.sh PROFILE_ID [PROFILE_ID...]
```

### Raw curl
```bash
# Single profile
curl -sS "https://www.geni.com/api/profile-6000000000841549574?\
fields=first_name,last_name,maiden_name,birth,death,gender,occupation&\
access_token=$GENI_TOKEN"

# Multiple profiles in one call
curl -sS "https://www.geni.com/api/profile-6000000000841549574?\
ids=6000000000841549574,6000000196127032824&\
access_token=$GENI_TOKEN"
```

### Profile fields
`first_name`, `last_name`, `maiden_name`, `gender`, `nicknames`, `birth` (event: date+location), `death` (event), `burial` (event), `occupation`, `cause_of_death`, `unions`, `is_alive`, `public`, `big_tree`, `profile_url`.

## Immediate Family: GET /api/profile-{ID}/immediate-family

```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/geni/scripts/geni-family.sh PROFILE_ID
```

### Raw curl
```bash
curl -sS "https://www.geni.com/api/profile-6000000000841549574/immediate-family?access_token=$GENI_TOKEN"
```

### Response
Returns `focus` (requested person) and `nodes` (hash of all immediate family profiles + union objects). Parse node keys: `profile-*` = person, `union-*` = marriage/partnership.

## Ancestors: GET /api/profile-{ID}/ancestors

```bash
curl -sS "https://www.geni.com/api/profile-XXXXX/ancestors?\
generations=10&\
access_token=$GENI_TOKEN"
```

Up to 20 generations. Returns nested ancestor tree.

## Union (Marriage): GET /api/union-{ID}

```bash
curl -sS "https://www.geni.com/api/union-XXXXX?access_token=$GENI_TOKEN"
```

Fields: `partners`, `children`, `adopted_children`, `status` (spouse/ex_spouse), `marriage` (event), `divorce` (event).

## Relationship Path: GET /api/profile-{ID}/path-to/profile-{ID}

```bash
curl -sS "https://www.geni.com/api/profile-XXXXX/path-to/profile-YYYYY?access_token=$GENI_TOKEN"
```

Can be async — if response `status` is "pending", poll again after 2-3 seconds.

## Rate Limits

Communicated via response headers:
- `X-API-Rate-Limit` — max requests per window
- `X-API-Rate-Remaining` — remaining in current window
- `X-API-Rate-Window` — window duration in seconds

Actual limits are not published. Add 1-2 second delays between requests. Scripts check remaining quota from headers and pause if low.

## Source Citation Format

```
[S: source="Geni.com" | profile_id=PROFILE_ID | url="https://www.geni.com/people/NAME/ID" | record="SURNAME, Given | b.YEAR | PLACE | managed by USER"]
```

## Search Strategy for Genealogy Research

1. **Search by surname** — `geni-search.sh "SURNAME"`
2. **Filter results client-side** — match birth year (±5), birthplace, and known family names
3. **Fetch full profile** — `geni-profile.sh PROFILE_ID` for confirmed matches
4. **Get immediate family** — `geni-family.sh PROFILE_ID` to find parents, siblings, children
5. **Cross-reference** — compare Geni tree data with JewishGen vital records

## Tips

- Profile IDs are in format `6000000XXXXXXXXX`
- Some profiles are private (`public: false`) — you'll see the name but limited details
- Dean (DeanLa) manages the MAREK/Hugo family profiles on Geni
- Birth/death events may have partial dates (year only) or no location
- The `big_tree` field indicates if the profile is connected to Geni's World Family Tree
