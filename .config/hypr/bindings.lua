-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Open the default browser with Super+W instead of closing the focused window.
hl.unbind("SUPER + W")
o.bind("SUPER + W", "Browser", { omarchy = "browser" })

-- Dictation push-to-talk on Left Alt + the AltGr key. wev reports AltGr as
-- keycode 108 (ISO_Level3_Shift), and Left Alt is the Mod1 modifier.
hl.unbind("ALT + Alt_R")
o.bind_hold(
  "ALT + code:108",
  "Start dictation (push-to-talk)",
  "omarchy-dictation start",
  "Stop dictation (push-to-talk)",
  "omarchy-dictation stop"
)

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")
