---
name: firefox-top-glass
description: Install, repair, inspect, or remove top-only translucent Firefox chrome on Omarchy/Hyprland while keeping webpages opaque. Use for recreating this machine's Firefox glass setup; do not use for ordinary Firefox color themes or transparent webpage content.
---

# Firefox Top Glass

Use the deterministic installer in `scripts/firefox-top-glass`; do not recreate
the CSS, preferences, or Hyprland rules by hand.

## Workflow

1. Run `scripts/firefox-top-glass status` to discover the active Firefox
   profile and inspect the managed components.
2. When the user asks to apply or repair the effect, run
   `scripts/firefox-top-glass install`. This installs the default `dark` theme.
   When the user requests a bundled theme, pass `--theme <name>`; currently
   available themes are `dark` and `nighthawks`.
3. Report that Firefox must be fully closed and reopened once. Do not close a
   running browser without the user's confirmation because tabs may contain
   unsaved work.
4. Use `scripts/firefox-top-glass remove` only when explicitly requested.

The installer creates timestamped backups and upserts marked blocks, preserving
unrelated Firefox and Hyprland customizations. It must never apply whole-window
opacity: Firefox's web-content surface stays opaque while only the chrome uses
per-pixel alpha. Do not edit generated CSS in the Firefox profile; theme color
tokens live in `assets/themes/` and shared glass behavior lives in
`assets/userChrome.css`.

If the installer cannot reach the live Hyprland socket, the file changes are
still valid. Follow the Omarchy skill to run `hyprctl reload` and
`hyprctl configerrors` with the required access. When modifying this skill's
Hyprland implementation, consult the current official Hyprland documentation
because rule syntax changes over time.
