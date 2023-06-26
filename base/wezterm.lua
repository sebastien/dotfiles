-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {
}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'AdventureTime'
config.window_background_opacity = 0.75


config.font_size = 10.0
config.font = wezterm.font("Iosevka Term")
config.freetype_load_target = "Light"

config.ssh_domains = {
  {
    name = 'bench',
    remote_address = 'bench.local',
    username = 'sebastien',
  },
}


-- and finally, return the configuration to wezterm
return config