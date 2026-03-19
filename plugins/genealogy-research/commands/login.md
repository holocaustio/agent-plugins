---
name: login
description: Authenticate to JewishGen
---

# /login — JewishGen Authentication

Authenticate to JewishGen databases. Required before any search operations.

## Step 1: Check Environment Variables

Verify that `JG_USER` and `JG_PASS` are set:

```bash
echo "JG_USER=${JG_USER:-(not set)}"
echo "JG_PASS=${JG_PASS:+[set]}"
```

If either is missing, tell the user:
```
Please set your JewishGen credentials:
  export JG_USER="your@email.com"
  export JG_PASS="yourpassword"
Then run /login again.
```

## Step 2: Check Existing Session

```bash
grep jgcure /tmp/jg_cookies.txt 2>/dev/null
```

If a valid session exists, report it and ask if the user wants to refresh anyway.

## Step 3: Run Login

```bash
${CLAUDE_PLUGIN_ROOT}/skills/data-sources/sources/jewishgen/scripts/jg-login.sh
```

## Step 4: Verify

```bash
grep jgcure /tmp/jg_cookies.txt
```

Report success or failure:
- **Success:** "Logged in as [email]. Session stored in /tmp/jg_cookies.txt. Ready to search."
- **Failure:** "Login failed. Check your JG_USER and JG_PASS credentials."
