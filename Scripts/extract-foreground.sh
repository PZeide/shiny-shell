#!/usr/bin/env bash

set -euo pipefail

validate_wallpaper() {
    local wallpaper="$1"

    if [[ ! -f "$wallpaper" ]]; then
        echo "wallpaper file '$wallpaper' does not exist" >&2
        exit 1
    fi

    if [[ ! -r "$wallpaper" ]]; then
        echo "wallpaper file '$wallpaper' is not readable" >&2
        exit 1
    fi
}

ensure_cache_dir() {
    local cache_dir="$1"

    if [[ ! -d "$cache_dir" ]]; then
        if ! mkdir -p "$cache_dir"; then
            echo "cannot create cache directory '$cache_dir'" >&2
            exit 1
        fi
    fi

    if [[ ! -w "$cache_dir" ]]; then
        echo "cache directory '$cache_dir' is not writable" >&2
        exit 1
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
        echo "rembg failed to process the image" >&2
        [[ -f "$output_file" ]] && rm -f "$output_file"
        exit 1
    fi

    if [[ ! -s "$output_file" ]]; then
        echo "rembg produced empty or invalid output" >&2
        [[ -f "$output_file" ]] && rm -f "$output_file"
        exit 1
    fi
}

main() {
    if [[ $# -ne 2 ]]; then
        echo "incorrect number of arguments" >&2
        exit 1
    fi

    local wallpaper_path="$1"
    local cache_path="$2"

    wallpaper_path=$(realpath "$wallpaper_path" 2>/dev/null) || {
        echo "cannot resolve wallpaper path '$1'" >&2
        exit 1
    }

    validate_wallpaper "$wallpaper_path"

    cache_path=$(realpath "$cache_path" 2>/dev/null) || {
        local parent_dir
        parent_dir=$(dirname "$cache_path")
        if [[ -d "$parent_dir" ]]; then
            cache_path="$parent_dir/$(basename "$cache_path")"
        else
            echo "cannot resolve cache path '$2'" >&2
            exit 1
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
