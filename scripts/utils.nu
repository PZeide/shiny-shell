const base_path = (path self | path dirname)

export def asset_path [filename: string] {
  $base_path | path join ".." "assets" $filename | path expand
}

export def require_dependency [cmd: string] {
  if (which $cmd | is-empty) {
    error make { msg: $"Required command '($cmd)' is not installed or not in PATH" }
  }
}
