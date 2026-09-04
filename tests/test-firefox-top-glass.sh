#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
COMMAND="$REPO_ROOT/scripts/firefox-top-glass"
TEST_ROOT=$(mktemp -d)
TEST_HOME="$TEST_ROOT/home"
TEST_CONFIG="$TEST_HOME/.config"
FIREFOX_ROOT="$TEST_CONFIG/mozilla/firefox"
PROFILE="$FIREFOX_ROOT/fixture.default-release"
HYPR_DIR="$TEST_CONFIG/hypr"

cleanup() {
  rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT

mkdir -p "$PROFILE/chrome" "$HYPR_DIR"

cat >"$FIREFOX_ROOT/profiles.ini" <<'EOF'
[General]
StartWithLastProfile=1
Version=2

[Profile0]
Name=default-release
IsRelative=1
Path=fixture.default-release
Default=1
EOF

cat >"$FIREFOX_ROOT/installs.ini" <<'EOF'
[fixture]
Default=fixture.default-release
Locked=1
EOF

printf '%s\n' '/* existing chrome customization */' >"$PROFILE/chrome/userChrome.css"
printf '%s\n' '// existing preference' >"$PROFILE/user.js"
printf '%s\n' '/* webpage content remains untouched */' >"$PROFILE/chrome/userContent.css"
printf '%s\n' '-- existing Hyprland setup' >"$HYPR_DIR/hyprland.lua"

CONTENT_HASH=$(sha256sum "$PROFILE/chrome/userContent.css")

HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_CONFIG" \
  "$COMMAND" install --no-reload >/dev/null

grep -Fqx '/* BEGIN firefox-top-glass */' "$PROFILE/chrome/userChrome.css"
grep -Fqx '// BEGIN firefox-top-glass' "$PROFILE/user.js"
grep -Fqx -- '-- BEGIN firefox-top-glass' "$HYPR_DIR/firefox-top-glass.lua"
grep -Fq 'require("hypr.firefox-top-glass")' "$HYPR_DIR/hyprland.lua"
grep -Fq 'existing chrome customization' "$PROFILE/chrome/userChrome.css"
grep -Fq 'existing preference' "$PROFILE/user.js"

FIRST_HASHES=$(sha256sum \
  "$PROFILE/chrome/userChrome.css" \
  "$PROFILE/user.js" \
  "$HYPR_DIR/firefox-top-glass.lua" \
  "$HYPR_DIR/hyprland.lua")

HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_CONFIG" \
  "$COMMAND" install --no-reload >/dev/null

SECOND_HASHES=$(sha256sum \
  "$PROFILE/chrome/userChrome.css" \
  "$PROFILE/user.js" \
  "$HYPR_DIR/firefox-top-glass.lua" \
  "$HYPR_DIR/hyprland.lua")

[[ "$FIRST_HASHES" == "$SECOND_HASHES" ]]
[[ "$CONTENT_HASH" == "$(sha256sum "$PROFILE/chrome/userContent.css")" ]]

HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_CONFIG" \
  "$COMMAND" status >/dev/null

HOME="$TEST_HOME" XDG_CONFIG_HOME="$TEST_CONFIG" \
  "$COMMAND" remove --no-reload >/dev/null

! grep -Fq 'BEGIN firefox-top-glass' "$PROFILE/chrome/userChrome.css"
! grep -Fq 'BEGIN firefox-top-glass' "$PROFILE/user.js"
! grep -Fq 'BEGIN firefox-top-glass' "$HYPR_DIR/hyprland.lua"
! grep -Fq 'BEGIN firefox-top-glass' "$HYPR_DIR/firefox-top-glass.lua"
grep -Fq 'existing chrome customization' "$PROFILE/chrome/userChrome.css"
grep -Fq 'existing preference' "$PROFILE/user.js"
grep -Fq 'existing Hyprland setup' "$HYPR_DIR/hyprland.lua"
[[ "$CONTENT_HASH" == "$(sha256sum "$PROFILE/chrome/userContent.css")" ]]

printf '%s\n' 'ok: install, idempotency, status, removal, and content preservation'
