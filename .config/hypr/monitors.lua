-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = "auto"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Desktop monitor (2560x1440 @ scale 1 = 2560x1440 logical), far left.
-- 164.84Hz is the panel's 165Hz mode as reported by EDID.
hl.monitor({ output = "DP-7", mode = "2560x1440@164.84", position = "0x0", scale = 1 })

-- Laptop panel to the right of the desktop
-- (3840x2400 @ scale 2 = 1920x1200 logical, so it starts at x=2560).
hl.monitor({ output = "eDP-1", mode = "3840x2400@60", position = "2560x0", scale = 2 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-7", mode = "preferred", position = "auto", scale = 1, transform = 1 })
