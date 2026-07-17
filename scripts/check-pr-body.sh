#!/usr/bin/env bash

set -euo pipefail

required_sections=(
  "## Spec / PRD"
  "## Acceptance Criteria / Test Scenarios"
  "## Solution / Design Plan"
  "## Tests"
  "## Release Risk"
)

body="${PR_BODY:-}"

if [[ -z "${body//[[:space:]]/}" ]]; then
  echo "Pull request body is empty."
  exit 1
fi

normalize_body() {
  printf '%s\n' "$body" | sed 's/\r$//'
}

section_content() {
  local heading="$1"
  normalize_body | awk -v heading="$heading" '
    $0 == heading { in_section = 1; next }
    /^## / && in_section { exit }
    in_section { print }
  '
}

has_meaningful_content() {
  local content="$1"
  local trimmed
  trimmed="$(printf '%s\n' "$content" | sed '/^[[:space:]]*$/d')"

  [[ -n "${trimmed//[[:space:]]/}" ]] || return 1
  [[ ! "$trimmed" =~ ^[[:space:]\-\*\[\]xX0-9.]+$ ]] || return 1
  [[ ! "$trimmed" =~ ^[[:space:]]*(TBD|TODO|N/?A|none|same as title)[[:space:]]*$ ]] || return 1

  return 0
}

for heading in "${required_sections[@]}"; do
  if ! normalize_body | grep -Fqx "$heading"; then
    echo "Missing required section: $heading"
    exit 1
  fi

  content="$(section_content "$heading")"
  if ! has_meaningful_content "$content"; then
    echo "Section is blank or placeholder-only: $heading"
    exit 1
  fi
done

echo "Pull request body includes all required inputs."
