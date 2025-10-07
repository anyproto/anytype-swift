#!/usr/bin/env bash
# Print the latest nightly version (by created_at) for org-scoped Maven package:
#   org: anyproto
#   package: io.anyproto.anytype-heart-ios
# STDOUT: version string (e.g., v0.44.0-nightly.20250902.1)
# STDERR: diagnostics only
# Exit code: 0 on success, non-zero on failure
# Requirements: curl, jq
# Auth: needs read:packages scope for the org

BASEDIR=$(dirname $0)

. ${BASEDIR}/common.sh --source-only

if [ "$CI" = true ] ; then
    if [[  -z "$MIDDLEWARE_TOKEN" ]]; then
        printf "MIDDLEWARE_TOKEN is not set\n"
        exit 1
    fi
    token=${MIDDLEWARE_TOKEN}
else
    has_token=$(has-keychain-environment-variable MIDDLEWARE_TOKEN)
    if [ ${has_token} == 0 ] ; then
        set-keychain-environment-variable MIDDLEWARE_TOKEN
    fi
    token=$(keychain-environment-variable MIDDLEWARE_TOKEN)
fi

ORG="anyproto"
PACKAGE_NAME="io.anyproto.anytype-heart-ios"
BASE_URL="https://api.github.com/orgs/${ORG}/packages/maven/${PACKAGE_NAME}/versions"

# Ensure jq exists
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed. Please install jq and try again." >&2
  exit 1
fi

# GitHub API GET that prints body then HTTP code on a new line
gh_get() {
  local url="$1"
  curl -sS \
    -H "Authorization: token ${token}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -w "\n%{http_code}\n" \
    "$url"
}

per_page=100
page=1
max_pages=50
latest_name=""
latest_date=""

while [ $page -le $max_pages ] ; do
  url="${BASE_URL}?per_page=${per_page}&page=${page}"
  resp="$(gh_get "${url}")" || true
  http_code="$(printf '%s' "${resp}" | tail -n1)"
  body="$(printf '%s' "${resp}" | sed -e '$d')"

  if [ "${http_code}" != "200" ]; then
    echo "Failed to fetch package versions (HTTP ${http_code}) from: ${url}" >&2
    msg="$(echo "${body}" | jq -r '.message // empty' 2>/dev/null || true)"
    if [ -n "${msg}" ]; then
      echo "API message: ${msg}" >&2
    fi
    exit 1
  fi

  # Stop if page is empty
  if jq -e 'length == 0' >/dev/null <<<"$body"; then
    break
  fi

  # Pick the latest nightly on this page
  page_candidate_json=$(jq -r '
    [.[] 
      | select(.name | test("night"; "i"))
      | {name: .name, created_at: .created_at}
    ]
    | sort_by(.created_at)
    | last // empty
  ' <<<"$body")

  if [ -n "${page_candidate_json}" ] && [ "${page_candidate_json}" != "null" ]; then
    cand_name=$(jq -r '.name' <<<"$page_candidate_json")
    cand_date=$(jq -r '.created_at' <<<"$page_candidate_json")
    if [ -z "${latest_date}" ] || [[ "${cand_date}" > "${latest_date}" ]]; then
      latest_name="${cand_name}"
      latest_date="${cand_date}"
    fi
  fi

  page=$((page+1))
done

if [ -z "${latest_name}" ]; then
  echo "No nightly version found for '${PACKAGE_NAME}'." >&2
  exit 1
fi

# Print version ONLY
printf "%s\n" "${latest_name}"