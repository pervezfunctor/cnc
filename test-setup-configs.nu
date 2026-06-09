#!/usr/bin/env nu

const TEST_HOME = "/tmp/test-wm-config-setup"
const SCRIPT = "./setup-configs.nu"

let MC = $"($TEST_HOME)/.config/mango/config.conf"
let NC = $"($TEST_HOME)/.config/niri/config.kdl"
let AC = $"($TEST_HOME)/.config/alacritty/alacritty.toml"

let MD = $"($TEST_HOME)/.config/mango"
let ND = $"($TEST_HOME)/.config/niri"
let AD = $"($TEST_HOME)/.config/alacritty"

let passed = {|msg| print $"  PASS: ($msg)" }
let failed = {|msg| print $"  FAIL: ($msg)"; exit 1 }

def setup [] {
    rm -rf $TEST_HOME
    mkdir $MD
    mkdir $ND
    mkdir $AD
}

def teardown [] {
    rm -rf $TEST_HOME
}

def run-script [] {
    with-env { HOME: $TEST_HOME } { nu $SCRIPT } | complete
}

# =============================================================================
print "=== Test Suite: setup-configs.nu ==="
let start = (date now)

# 1. Missing mango config (setup creates dirs only, no files)
print "--- Test 1: Error on missing mango config ---"
setup
let r = (run-script)
if $r.exit_code == 0 { do $failed "should exit non-zero" }; do $passed "exits non-zero"
if ($r.stderr | str contains "mango config.conf not found") == false { do $failed "wrong error" }; do $passed "correct error message"
teardown

# 2. Missing niri config (touch mango but leave niri absent)
print "--- Test 2: Error on missing niri config ---"
setup
touch $MC
# $NC intentionally not created
let r = (run-script)
if $r.exit_code == 0 { do $failed "should exit non-zero" }; do $passed "exits non-zero"
if ($r.stderr | str contains "niri config.kdl not found") == false { do $failed "wrong error" }; do $passed "correct error message"
teardown

# 3. Missing alacritty config (touch mango+niri but leave alacritty absent)
print "--- Test 3: Error on missing alacritty config ---"
setup
touch $MC
touch $NC
# $AC intentionally not created
let r = (run-script)
if $r.exit_code == 0 { do $failed "should exit non-zero" }; do $passed "exits non-zero"
if ($r.stderr | str contains "alacritty config.toml not found") == false { do $failed "wrong error" }; do $passed "correct error message"
teardown

# 4. First run adds all directives
print "--- Test 4: First run adds all directives ---"
setup
touch $MC
touch $NC
"[general]" | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"
if ($r.stdout | str contains "mango: added") == false { do $failed "mango not in output" }
if ($r.stdout | str contains "niri: added") == false { do $failed "niri not in output" }
if ($r.stdout | str contains "alacritty: added") == false { do $failed "alacritty not in output" }
do $passed "all 'added' messages printed"

let mango = (open --raw $MC)
if ($mango | str contains "source=~/.config/mango/custom.conf") == false { do $failed "mango missing source line" }
do $passed "mango has source line"

let niri = (open --raw $NC)
if ($niri | str contains "include ") == false or ($niri | str contains "custom.kdl") == false { do $failed "niri missing include" }
do $passed "niri has include line"

let ala = (open --raw $AC)
if ($ala | str contains "custom.toml") == false { do $failed "alacritty missing custom.toml" }
do $passed "alacritty has custom.toml include"
teardown

# 5. Idempotent (already configured)
print "--- Test 5: Second run is idempotent ---"
setup
touch $MC
touch $NC
"[general]" | save -f $AC
# First run
run-script | ignore
# Second run
let r = (run-script)
if $r.exit_code != 0 { do $failed $"second run failed: ($r.stderr)" }; do $passed "second run exits zero"
if ($r.stdout | str contains "already configured") == false { do $failed "should report already configured" }
do $passed "reports already configured"

let mango = (open --raw $MC)
let niri = (open --raw $NC)
let ala = (open $AC)
if (($mango | lines | where $in =~ "custom.conf" | length) > 1) { do $failed "mango duplicate" }
if (($niri | lines | where $in =~ "custom.kdl" | length) > 1) { do $failed "niri duplicate" }
do $passed "no duplicate lines"

let inc = ($ala | get -o general | default {} | get -o import | default [])
if ($inc | length) != 1 { do $failed $"expected 1 import, got ($inc | length)" }
do $passed "alacritty has exactly 1 import"
teardown

# 6. Pre-existing directives
print "--- Test 6: Pre-existing directives detected ---"
setup
'source=~/.config/mango/custom.conf' | save -f $MC
'include "./cfg/custom.kdl"' | save -f $NC
'[general]
import = ["~/.config/alacritty/custom.toml"]' | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"
if ($r.stdout | str contains "already configured") == false { do $failed "should say already configured" }
do $passed "all report already configured"
teardown

# 7. Alacritty with no [general] section
print "--- Test 7: Alacritty with no [general] section ---"
setup
touch $MC
touch $NC
'[colors]
primary = { background = "#000" }' | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"

let ala = (open $AC)
    let gen = ($ala | get -o general | default {})
    let includes = ($gen | get -o import | default [])
    if ($includes | length) != 1 { do $failed $"expected 1 import, got ($includes | length)" }
    if ($includes.0 | str contains "custom.toml") == false { do $failed "import should contain custom.toml" }
    do $passed "alacritty [general] created with custom.toml import"
teardown

# 8. Alacritty with [general] but no include
print "--- Test 8: Alacritty with [general] but no include ---"
setup
touch $MC
touch $NC
'[general]
live_config_reload = true
[font]
size = 12' | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"

let ala = (open $AC)
    let includes = ($ala.general.import | default [])
    if ($includes | length) != 1 { do $failed $"expected 1 import, got ($includes | length)" }
    if ($includes.0 | str contains "custom.toml") == false { do $failed "import should be custom.toml" }
    if $ala.font.size != 12 { do $failed "existing font config not preserved" }
    do $passed "existing config preserved, import added"
teardown

# 9. Alacritty with existing includes (should append)
print "--- Test 9: Append to existing include list ---"
setup
touch $MC
touch $NC
    '[general]
    import = ["~/.config/alacritty/theme.toml", "~/.config/alacritty/other.toml"]' | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"

let ala = (open $AC)
    let includes = ($ala.general.import | default [])
    if ($includes | length) != 3 { do $failed $"expected 3 imports, got ($includes | length)" }
    if ($includes.2 | str contains "custom.toml") == false { do $failed "third import should be custom.toml" }
    if ($includes.0 | str contains "theme.toml") == false { do $failed "first import changed" }
    if ($includes.1 | str contains "other.toml") == false { do $failed "second import changed" }
    do $passed "custom.toml appended to existing import list"
teardown

# 10. Mango with existing source= lines
print "--- Test 10: Mango with existing source= lines ---"
setup
'source=~/.config/mango/dms/colors.conf
source=~/.config/mango/dms/cursor.conf' | save -f $MC
touch $NC
'[general]' | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"

let mango = (open --raw $MC)
let source_lines = ($mango | lines | where $in =~ "source=" | length)
if $source_lines != 3 { do $failed $"expected 3 source= lines, got ($source_lines)" }
do $passed "custom.conf appended after existing source= lines"
teardown

# 11. Niri with existing include lines
print "--- Test 11: Niri with existing include lines ---"
setup
touch $MC
'include "./cfg/keybinds.kdl"
include "./cfg/layout.kdl"' | save -f $NC
'[general]' | save -f $AC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"

let niri = (open --raw $NC)
let inc_lines = ($niri | lines | where $in =~ "include" | length)
if $inc_lines != 3 { do $failed $"expected 3 include lines, got ($inc_lines)" }
do $passed "custom.kdl appended after existing include lines"
teardown

# =============================================================================
let elapsed = ((date now) - $start) | format duration sec
print $"=== All tests passed in ($elapsed) ==="
