-- Provide blur behind app-native translucent surfaces. Firefox keeps its
-- web-content surface opaque; only its transparent chrome uses this effect.
hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      ignore_opacity = true,
      new_optimizations = true,
    },
  },
})

-- Preserve Firefox's per-pixel alpha without fading the entire window when it
-- loses focus. Whole-window opacity would also make webpages translucent.
o.window("([fF]irefox)", { opacity = "1.0 override 1.0 override" })
