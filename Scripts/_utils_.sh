#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

asset_path() {
  echo "$BASEDIR/../Assets/$1"
}

error_exit() {
  echo "$1" >&2
  exit 1
}

require_dependency() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    error_exit "required command '$cmd' is not installed or not in PATH."
  fi
}
