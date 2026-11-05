-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.

-- Monitor configuration is per machine. monitors.default.lua is the shared
-- baseline; a machine's own monitors.lua is loaded after it and wins. That file
-- is rewritten by hyprmoncfg and is not tracked in this repo.
for _, name in ipairs({ "monitors.default", "monitors" }) do
  local path = os.getenv("HOME") .. "/.config/hypr/" .. name .. ".lua"
  local file = io.open(path, "r")
  if file then
    file:close()
    dofile(path)
  end
end

require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Machine-specific overrides, one file per host in hypr/hosts/, picked by
-- hostname. Everything in the files above is shared by every machine.
do
  local host = "unknown"
  local name_file = io.open("/etc/hostname", "r")
  if name_file then
    host = (name_file:read("*l") or "unknown"):gsub("%s+$", "")
    name_file:close()
  end
  local path = os.getenv("HOME") .. "/.config/hypr/hosts/" .. host .. ".lua"
  local file = io.open(path, "r")
  if file then
    file:close()
    dofile(path)
  end
end

-- Load settings written by OmaControl (omacontrol:managed).
-- It belongs above the toggles below: those turn the laptop
-- display off with a monitor rule, and a rule of ours read
-- afterwards would replace it and put the display back on.
require("hypr.omacontrol")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Omarchy gives every window a slightly transparent default (0.985 active,
-- 0.96 inactive). Keep the active window fully opaque and inactive at
-- Omarchy's 96%.
o.window({ tag = "default-opacity" }, { opacity = "0.995 0.96" })

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
do local path = os.getenv("HOME") .. "/.config/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
