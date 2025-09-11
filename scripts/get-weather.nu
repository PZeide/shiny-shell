#!/usr/bin/env nu

const utils_path = (path self | path dirname | path join "utils.nu")
use $utils_path

def fetch_weather_data [lat: float, lon: float] {
  let url = $"https://api.open-meteo.com/v1/forecast?latitude=($lat)&longitude=($lon)&current=temperature_2m,weather_code,is_day"
  let response = http get $url
  return $response
}

def parse_weather_data [code: int, is_day: int] {
  let icon_suffix = if $is_day == 1 { "_day" } else { "_night" }

  match $code {
    0 => { weather: "Clear sky", icon: $"clear($icon_suffix)" }
    1 => { weather: "Mainly clear", icon: $"partly_cloudy($icon_suffix)" }
    2 => { weather: "Partly cloudy", icon: $"partly_cloudy($icon_suffix)" }
    3 => { weather: "Cloudy", icon: "cloud" }
    45 | 48 => { weather: "Foggy", icon: "foggy" }
    51 | 53 | 55 | 56 | 57 => { weather: "Drizzle", icon: "grain" }
    61 | 63 | 65 | 66 | 67 => { weather: "Rain", icon: "rainy" }
    71 | 73 | 75 | 77 => { weather: "Snow", icon: "ac_unit" }
    80 | 81 | 82 => { weather: "Rain showers", icon: "rainy" }
    85 | 86 => { weather: "Snow showers", icon: "ac_unit" }
    95 => { weather: "Thunderstorm", icon: "thunderstorm" }
    96 | 99 => { weather: "Thunderstorm with hail", icon: "thunderstorm" }
    _ => { error make { msg: $"Unknown weather code ($code)" } }
  }
}

def main [lat: float, lon: float] {
  let response = fetch_weather_data $lat $lon

  let temp = $response.current.temperature_2m
  let code = $response.current.weather_code
  let is_day = $response.current.is_day

  if ($temp == null or $code == null or $is_day == null) {
    error make { msg: "Invalid data received from api" }
  }

  let parsed = parse_weather_data $code $is_day

  {
    weather: $parsed.weather
    icon: $parsed.icon
    temperature: $temp
  } | to json --raw
}
