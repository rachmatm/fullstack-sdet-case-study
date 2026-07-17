#!/usr/bin/env bash

set -euo pipefail

tag_name="${TAG_NAME:-unknown-tag}"
api_rspec_result="${API_RSPEC_RESULT:-missing}"
web_build_result="${WEB_BUILD_RESULT:-missing}"
release_notes_result="${RELEASE_NOTES_RESULT:-missing}"
verdict_file="${VERDICT_FILE:-release-verdict.md}"

blocked_reasons=()

if [[ "${api_rspec_result}" != "success" ]]; then
  blocked_reasons+=("api-rspec=${api_rspec_result}")
fi

if [[ "${web_build_result}" != "success" ]]; then
  blocked_reasons+=("web-build=${web_build_result}")
fi

if [[ "${release_notes_result}" != "success" ]]; then
  blocked_reasons+=("release-notes=${release_notes_result}")
fi

verdict="releasable"
if (( ${#blocked_reasons[@]} > 0 )); then
  verdict="blocked"
fi

{
  echo "## Release Verdict"
  echo
  echo "- Tag: \`${tag_name}\`"
  echo "- Backend regression gate: \`${api_rspec_result}\`"
  echo "- Frontend build gate: \`${web_build_result}\`"
  echo "- Release notes check: \`${release_notes_result}\`"
  echo "- Final recommendation: \`${verdict}\`"
  echo

  if (( ${#blocked_reasons[@]} > 0 )); then
    echo "### Blocking Reasons"
    echo
    for reason in "${blocked_reasons[@]}"; do
      echo "- ${reason}"
    done
  else
    echo "All configured release checks passed for this tag."
  fi
} > "${verdict_file}"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  cat "${verdict_file}" >> "${GITHUB_STEP_SUMMARY}"
fi

cat "${verdict_file}"

if [[ "${verdict}" == "blocked" ]]; then
  exit 1
fi
