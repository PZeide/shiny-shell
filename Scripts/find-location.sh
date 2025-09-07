#!/usr/bin/env bash

set -euo pipefail

BASEDIR=$(dirname "$0")
source "$BASEDIR/_utils_.sh"

validate_provider() {
  local provider="$1"

  case "$provider" in
  auto | ipinfo) ;;
  *)
    error_exit "invalid provider '$provider'; must be one of: auto, ipinfo"
    ;;
  esac
}

query_ipinfo() {
  require_dependency "curl"
  require_dependency "jq"

  local country_data_file
  country_data_file=$(asset_path "countries.json")
  if [[ ! -r "$country_data_file" ]]; then
    error_exit "cannot read the country data file"
  fi

  local response
  response=$(curl -fsSL https://ipinfo.io/json) || return 1

  local country_code city loc
  country_code=$(echo "$response" | jq -r '.country // "Unknown"') || return 1
  city=$(echo "$response" | jq -r '.city // "Unknown"') || return 1
  loc=$(echo "$response" | jq -r '.loc') || return 1

  local country_name
  country_name=$(jq -r ".\"$country_code\" // \"Unknown\"" "$country_data_file") || return 1

  local lat lon
  IFS=',' read -r lat lon <<<"$loc"

  jq -n --arg country_code "$country_code" \
    --arg country_name "$country_name" \
    --arg city "$city" \
    --arg lat "$lat" \
    --arg lon "$lon" \
    '{countryCode: $country_code, countryName: $country_name, city: $city, latitude: ($lat | tonumber), longitude: ($lon | tonumber)}'
}

main() {
  if [[ $# -ne 1 ]]; then
    error_exit "usage: $0 <provider>"
  fi

  local provider="$1"
  validate_provider "$provider"

  case "$provider" in
  ipinfo)
    query_ipinfo || error_exit "ipinfo provider failed"
    ;;
  auto)
    if query_ipinfo; then
      exit 0
    else
      error_exit "every location providers failed"
    fi
    ;;
  esac
}

main "$@"
