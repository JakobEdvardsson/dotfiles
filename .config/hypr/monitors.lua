-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Any monitor without a specific rule (the external display) is placed to the
-- left of the laptop. This follows whichever monitor is connected, so no output
-- name needs to be maintained when switching devices.
hl.monitor({ output = "", mode = "preferred", position = "auto-left", scale = omarchy_monitor_scale })

-- Laptop panel is the reference point at the origin.
-- (3840x2400 @ scale 2 = 1920x1200 logical.)
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 2 })
