#!/usr/bin/env nu

const utils_path = (path self | path dirname | path join "utils.nu")
use $utils_path

def exec_rembg [input_file: string output_file: string] {
  try {
    ^rembg i -m birefnet-general $input_file $output_file
  } catch {|e|
    print $e.exit_code

    if ($output_file | path exists) {
      rm $output_file
    }

    error make { msg:  "Failed to process the image" }
  }
}

def main [wallpaper_path: string, cache_path: string] {
  utils require_dependency "rembg"

  if not ($wallpaper_path | path exists) {
    error make { msg: $"Wallpaper file '($wallpaper_path)' does not exist" }
  }

  if not ($cache_path | path exists) {
    if not (mkdir $cache_path) {
      error make { msg: $"Cannot create cache directory '($cache_path)'" }
    }
  }

  let wallpaper_hash = open $wallpaper_path | hash sha256
  let output_path = $cache_path | path join $"foreground-($wallpaper_hash).png"
  if ($output_path | path exists) {
    return $output_path
  }

  exec_rembg $wallpaper_path $output_path
  $output_path
}
