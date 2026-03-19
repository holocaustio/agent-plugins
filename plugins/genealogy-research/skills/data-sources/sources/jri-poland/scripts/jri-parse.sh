#!/usr/bin/env bash
# Parse JRI-Poland Detail HTML (singleline=Y format)
# Reads HTML from stdin, outputs tab-separated records.
# Usage: cat response.html | jri-parse.sh
#    or: jri-search.sh SURNAME | jri-parse.sh
#
# Output columns (TSV):
#   Surname  GivenName  Year  Type  Akt  Page  Sex  DOB  Father  FatherSurname  Mother  MotherSurname  Comments
#
# Compatible with macOS default awk/sed (no GNU extensions required).

set -euo pipefail

# Read all input
HTML=$(LC_ALL=C cat)

# Check for no-results
if echo "$HTML" | LC_ALL=C grep -qi "no records found\|0 records found"; then
  echo "# No records found" >&2
  exit 0
fi

# Print record count if found
REC_COUNT=$(echo "$HTML" | LC_ALL=C grep -aoE '[0-9][0-9,]* records? found' | head -1 || true)
if [[ -n "$REC_COUNT" ]]; then
  echo "# $REC_COUNT" >&2
fi

# Print header
printf 'Surname\tGivenName\tYear\tType\tAkt\tPage\tSex\tDOB\tFather\tFatherSurname\tMother\tMotherSurname\tComments\n'

# Parse the HTML table.
# JRI-Poland singleline format puts all fields in sequential <td> cells.
# The full field order (41 fields per record) is:
#  0  Surname
#  1  Given Name
#  2  Year
#  3  Type (B/M/D/V/H)
#  4  Akta (record number)
#  5  Page
#  6  District
#  7  Sygnatura
#  8  House#
#  9  Sex
# 10  Age/Born
# 11  DateBirth
# 12  DateMarriage
# 13  DateDeath
# 14  DateRegistration
# 15  TownBirth
# 16  TownMarriage
# 17  TownDeath
# 18  TownResidence
# 19  CauseOfDeath
# 20  Spouse
# 21  SpouseSurname
# 22  MaidenName
# 23  Patronymic
# 24  OtherSurnames
# 25  Occupation
# 26  FatherOccupation
# 27  Father
# 28  FatherSurname
# 29  Mother
# 30  MotherSurname
# 31  FatherAge
# 32  MotherAge
# 33  FatherTown
# 34  MotherTown
# 35  FatherFather
# 36  MotherFather
# 37  FatherMother
# 38  MotherMother
# 39  Comments
# 40  ExtraInfo
#
# We extract fields: 0,1,2,3,4,5,9,11,27,28,29,30,39

echo "$HTML" | LC_ALL=C awk '
BEGIN {
  # We want to extract <td> contents from the HTML
  # First, normalize everything to one line per <td>
}
{
  gsub(/\r/, "")
  buf = buf $0 " "
}
END {
  # Split on <td tags (case insensitive workaround: match both)
  n = split(buf, cells, /<[Tt][Dd][^>]*>/)

  # fields_per_record for singleline format
  FPR = 41

  # We need to find where records start.
  # Strip tags from each cell and collect clean values
  delete vals
  nvals = 0
  for (i = 2; i <= n; i++) {
    val = cells[i]
    # Remove closing </td> and everything after
    sub(/<\/[Tt][Dd]>.*/, "", val)
    # Remove all HTML tags
    gsub(/<[^>]*>/, "", val)
    # Decode common HTML entities
    gsub(/&amp;/, "\\&", val)
    gsub(/&lt;/, "<", val)
    gsub(/&gt;/, ">", val)
    gsub(/&quot;/, "\"", val)
    gsub(/&#39;/, "\x27", val)
    gsub(/&nbsp;/, " ", val)
    gsub(/&#160;/, " ", val)
    # German umlauts
    gsub(/&#252;/, "ü", val)
    gsub(/&#228;/, "ä", val)
    gsub(/&#246;/, "ö", val)
    gsub(/&#220;/, "Ü", val)
    gsub(/&#196;/, "Ä", val)
    gsub(/&#214;/, "Ö", val)
    gsub(/&#223;/, "ß", val)
    # Polish characters
    gsub(/&#322;/, "l", val)
    gsub(/&#324;/, "n", val)
    gsub(/&#347;/, "s", val)
    gsub(/&#263;/, "c", val)
    gsub(/&#380;/, "z", val)
    gsub(/&#378;/, "z", val)
    gsub(/&#261;/, "a", val)
    gsub(/&#281;/, "e", val)
    gsub(/&#243;/, "o", val)
    # Trim whitespace
    gsub(/^[ \t\n]+/, "", val)
    gsub(/[ \t\n]+$/, "", val)
    # Normalize internal whitespace
    gsub(/[ \t\n]+/, " ", val)
    nvals++
    vals[nvals] = val
  }

  # Now find record boundaries. We look for sequences of FPR cells
  # where field[3] (Type, 0-indexed) matches B|M|D|V|H|O
  # Skip header rows (they contain the column names like "Surname", "Given Name")

  for (start = 1; start + FPR - 1 <= nvals; start++) {
    type_val = vals[start + 3]
    # Valid record types
    if (type_val !~ /^[BMDVHO]$/) continue

    # Check year field is numeric-ish
    year_val = vals[start + 2]
    if (year_val !~ /^[0-9]/) continue

    # Extract the fields we want
    surname     = vals[start + 0]
    givenname   = vals[start + 1]
    year        = vals[start + 2]
    rectype     = vals[start + 3]
    akt         = vals[start + 4]
    page        = vals[start + 5]
    sex         = vals[start + 9]
    dob         = vals[start + 11]
    father      = vals[start + 27]
    fathersur   = vals[start + 28]
    mother      = vals[start + 29]
    mothersur   = vals[start + 30]
    comments    = vals[start + 39]

    # Skip if surname looks like a header label
    if (surname == "Surname" || surname == "surname") continue

    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
      surname, givenname, year, rectype, akt, page, sex, dob, \
      father, fathersur, mother, mothersur, comments

    # Advance past this record
    start = start + FPR - 1
  }
}
'
