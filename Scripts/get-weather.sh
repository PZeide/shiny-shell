#!/usr/bin/env bash

set -euo pipefail

error_exit() {
    echo "$1" >&2
    exit 1
}

validate_coordinates() {
    local lat="$1"
    local lon="$2"

    if [[ ! "$lat" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || [[ ! "$lon" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
        error_exit "invalid coordinates: latitude and longitude must be numeric"
    fi
}

get_weather_data() {
    local lat="$1"
    local lon="$2"

    curl -fsSL "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&current=temperature_2m,weather_code,is_day" ||
        error_exit "failed to fetch weather data from Open-Meteo"
}

parse_weather_data() {
    local code="$1"
    local is_day="$2"

    local icon_suffix=""
    if [[ "$is_day" == "1" ]]; then
        icon_suffix="_day"
    else
        icon_suffix="_night"
    fi

    # Mapping from Open-Meteo weather codes to (Display Name, Material Icon)
    case "$code" in
    0) echo "Clear sky|clear${icon_suffix}" ;;
    1) echo "Mainly clear|partly_cloudy${icon_suffix}" ;;
    2) echo "Partly cloudy|partly_cloudy${icon_suffix}" ;;
    3) echo "Cloudy|cloud" ;;
    45 | 48) echo "Foggy|foggy" ;;
    51 | 53 | 55 | 56 | 57) echo "Drizzle|grain" ;;
    61 | 63 | 65 | 66 | 67) echo "Rain|rainy" ;;
    71 | 73 | 75 | 77) echo "Snow|ac_unit" ;;
    80 | 81 | 82) echo "Rain showers|rainy" ;;
    85 | 86) echo "Snow showers|ac_unit" ;;
    95) echo "Thunderstorm|thunderstorm" ;;
    96 | 99) echo "Thunderstorm with hail|thunderstorm" ;;
    *) echo "Unknown|help" ;;
    esac
}

main() {
    if [[ $# -ne 2 ]]; then
        error_exit "usage: $0 <latitude> <longitude>"
    fi

    local lat="$1"
    local lon="$2"
    validate_coordinates "$lat" "$lon"

    local response
    response=$(get_weather_data "$lat" "$lon")

    local temp
    local code
    local is_day

    temp=$(echo "$response" | jq -r '.current.temperature_2m // empty') || error_exit "could not parse temperature"
    code=$(echo "$response" | jq -r '.current.weather_code // empty') || error_exit "could not parse weather code"
    is_day=$(echo "$response" | jq -r '.current.is_day // empty') || error_exit "could not parse is day"

    if [[ -z "$temp" || -z "$code" || -z "$is_day" ]]; then
        error_exit "incomplete data received from weather API"
    fi

    IFS='|' read -r display_name icon <<<"$(parse_weather_data "$code" "$is_day")"

    jq -n --arg weather "$display_name" --arg icon "$icon" --arg temperature "$temp" \
        '{weather: $weather, icon: $icon, temperature: ($temperature | tonumber)}'
}

main "$@"
