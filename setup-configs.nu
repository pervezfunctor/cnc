#!/usr/bin/env nu

def ensure-line [
    file: path
    line: string
    name: string
] {
  if not ($file | path exists) {
    print -e $"($name) ($file | path basename) not found"
    exit 1
  }

  let raw = (open --raw $file)

  if ($raw | lines | any {|l| $l == $line }) {
      print $"($name): already configured"
      return
  }

  ($raw
  | lines
  | append $line
  | str join "\n"
  ) | save -f $file

  print $"($name): added"
}

# MangoWM
ensure-line ($env.HOME | path join ".config" "mango" "config.conf") 'source=~/.config/mango/custom.conf' "mango"
# Niri
ensure-line ($env.HOME | path join ".config" "niri" "config.kdl") 'include "./cfg/custom.kdl"' "niri"

# Alacritty
let ap = ($env.HOME | path join ".config" "alacritty" "alacritty.toml")
if not ($ap | path exists) {
  print -e "alacritty config.toml not found"
  exit 1
}

let custom_include = "~/.config/alacritty/custom.toml"

let config = (open $ap)

let general = $config | get -o general | default {}
let imports = $general | get -o import | default []

if ($imports | any {|i| $i == $custom_include }) {
  print "alacritty: already configured"
} else {
  ($config | upsert general (
      $general | upsert import ($imports | append $custom_include)
    ) | to toml
  ) | save -f $ap

  print "alacritty: added"
}
