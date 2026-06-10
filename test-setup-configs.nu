#!/usr/bin/env nu

const TEST_HOME = "/tmp/test-wm-config-setup"
const SCRIPT = "./.local/bin/post-cmc"

let NC = $"($TEST_HOME)/.config/niri/config.kdl"
let ND = $"($TEST_HOME)/.config/niri"

let passed = {|msg| print $"  PASS: ($msg)" }
let failed = {|msg| print $"  FAIL: ($msg)"; exit 1 }

def setup [] {
    rm -rf $TEST_HOME
    mkdir $ND
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

# 1. Missing niri config (setup creates dir only, no files)
print "--- Test 1: Skip on missing niri config ---"
setup
let r = (run-script)
if $r.exit_code != 0 { do $failed "should exit zero" }; do $passed "exits zero"
if ($r.stderr | str contains "niri config.kdl not found, skipping") == false { do $failed "wrong message" }; do $passed "correct skip message"
teardown

# 2. First run adds niri include
print "--- Test 2: First run adds niri include ---"
setup
touch $NC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"
if ($r.stdout | str contains "niri: added") == false { do $failed "niri not in output" }; do $passed "niri 'added' message printed"

let niri = (open --raw $NC)
if ($niri | str contains "include ") == false or ($niri | str contains "custom.kdl") == false { do $failed "niri missing include" }
do $passed "niri has include line"
teardown

# 3. Idempotent (already configured)
print "--- Test 3: Second run is idempotent ---"
setup
touch $NC
# First run
run-script | ignore
# Second run
let r = (run-script)
if $r.exit_code != 0 { do $failed $"second run failed: ($r.stderr)" }; do $passed "second run exits zero"
if ($r.stdout | str contains "already configured") == false { do $failed "should report already configured" }; do $passed "reports already configured"

let niri = (open --raw $NC)
if (($niri | lines | where $in =~ "custom.kdl" | length) > 1) { do $failed "niri duplicate" }
do $passed "no duplicate lines"
teardown

# 4. Pre-existing directives detected
print "--- Test 4: Pre-existing directives detected ---"
setup
'include "./cfg/custom.kdl"' | save -f $NC

let r = (run-script)
if $r.exit_code != 0 { do $failed $"script failed: ($r.stderr)" }; do $passed "exits zero"
if ($r.stdout | str contains "niri: already configured") == false { do $failed "should say already configured" }
do $passed "niri reports already configured"
teardown

# 5. Niri with existing include lines (append after)
print "--- Test 5: Niri with existing include lines ---"
setup
'include "./cfg/keybinds.kdl"
include "./cfg/layout.kdl"' | save -f $NC

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
