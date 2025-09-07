#!/usr/bin/env bash

set -euo pipefail

BASEDIR=$(dirname "$0")
source "$BASEDIR/_utils_.sh"

validate_wallpaper() {
  local wallpaper="$1"

  if [[ ! -f "$wallpaper" ]]; then
    error_exit "wallpaper file '$wallpaper' does not exist"
  fi

  if [[ ! -r "$wallpaper" ]]; then
    error_exit "wallpaper file '$wallpaper' is not readable"
  fi
}

ensure_cache_dir() {
  local cache_dir="$1"

  if [[ ! -d "$cache_dir" ]]; then
    if ! mkdir -p "$cache_dir"; then
      error_exit "cannot create cache directory '$cache_dir'"
    fi
  fi

  if [[ ! -w "$cache_dir" ]]; then
    error_exit "cache directory '$cache_dir' is not writable"
  fi
}

wallpaper_hash() {
  local wallpaper="$1"
  sha256sum "$wallpaper" | cut -d' ' -f1
}

wallpaper_extension() {
  local wallpaper="$1"
  echo "${wallpaper##*.}"
}

exec_rembg() {
  local input_file="$1"
  local output_file="$2"

  if ! rembg i -m birefnet-general "$input_file" "$output_file" >/dev/null 2>&1; then
    [[ -f "$output_file" ]] && rm -f "$output_file"
    error_exit "rembg failed to process the image"
  fi

  if [[ ! -s "$output_file" ]]; then
    [[ -f "$output_file" ]] && rm -f "$output_file"
    error_exit "rembg produced empty or invalid output"
  fi
}

main() {
  require_dependency "rembg"

  if [[ $# -ne 2 ]]; then
    error_exit "usage: $0 <wallpaper_path> <cache_path>"
  fi

  local wallpaper_path="$1"
  local cache_path="$2"

  wallpaper_path=$(realpath "$wallpaper_path" 2>/dev/null) || {
    error_exit "cannot resolve wallpaper path '$1'"
  }

  validate_wallpaper "$wallpaper_path"

  cache_path=$(realpath "$cache_path" 2>/dev/null) || {
    local parent_dir
    parent_dir=$(dirname "$cache_path")
    if [[ -d "$parent_dir" ]]; then
      cache_path="$parent_dir/$(basename "$cache_path")"
    else
      error_exit "cannot resolve cache path '$2'"
    fi
  }

  ensure_cache_dir "$cache_path"

  local wallpaper_hash
  wallpaper_hash=$(wallpaper_hash "$wallpaper_path")

  local extension
  extension=$(wallpaper_extension "$wallpaper_path")

  local output_file="$cache_path/foreground-${wallpaper_hash}.${extension}"

  if [[ -f "$output_file" ]] && [[ -s "$output_file" ]]; then
    # Already exists in cache
    echo "$output_file"
    exit 0
  fi

  exec_rembg "$wallpaper_path" "$output_file"

  echo "$output_file"
  exit 0
}

main "$@"
