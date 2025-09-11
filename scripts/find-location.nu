#!/usr/bin/env nu

const utils_path = (path self | path dirname | path join "utils.nu")
use $utils_path

def validate_provider [provider: string] {
  let valid_providers = ["auto", "ipinfo", "another_provider"]

 if not ($provider in $valid_providers) {
    error make { msg: $"Invalid provider '($provider)'; must be one of: ($valid_providers | str join ', ')" }
  }
}

def query_ipinfo [] {
  let url = "https://ipinfo.io/json"
  let response = http get $url
  let loc_parts = ($response.loc | split row ",")

  {
    countryCode: $response.country
    countryName: (open (utils asset_path "data/countries.json") | get $response.country)
    city: $response.city
    latitude: ($loc_parts.0 | into float)
    longitude: ($loc_parts.1 | into float)
  }
}

def main [provider: string] {
  validate_provider $provider

  match $provider {
    "ipinfo" => {
      query_ipinfo | to json --raw
    }
    "auto" => {
      try {
        query_ipinfo | to json --raw
      } catch {
        error make { msg: "Every location providers failed" }
      }
    }
  }
}
