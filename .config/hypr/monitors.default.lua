-- Shared monitor baseline, used by every machine.
--
-- This file is tracked. Each host also has its own monitors.lua, loaded right
-- after this one, which hyprmoncfg rewrites and which is deliberately not
-- tracked. Put laptop/mini-PC specifics in hypr/hosts/<hostname>.lua instead.

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Any monitor without a specific rule (typically the external display) is
-- placed to the left of the primary, so no output name has to be maintained
-- when switching devices.
hl.monitor({ output = "", mode = "preferred", position = "auto-left", scale = omarchy_monitor_scale })
