-- Machine: work (laptop).
--
-- Loaded by hyprland.lua by matching `hostname`, after the shared config. Put
-- anything that only applies to this machine here. On this host hyprmoncfg also
-- owns the live display layout, so keep these rules to a sensible fallback.

-- Laptop panel is the reference point at the origin.
-- (3840x2400 @ scale 2 = 1920x1200 logical.)
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 2 })
