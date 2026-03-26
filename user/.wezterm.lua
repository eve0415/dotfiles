local wezterm = require("wezterm")

local config = {}

-- =========================
-- Font
-- =========================

config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
})

config.font_size = 14.0
config.line_height = 1.05

-- =========================
-- Color scheme
-- =========================

config.color_scheme = "Catppuccin Mocha"

-- =========================
-- Window
-- =========================

config.window_padding = {
	left = 6,
	right = 6,
	top = 6,
	bottom = 6,
}

config.window_background_opacity = 1.0

-- =========================
-- Tab bar
-- =========================

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- =========================
-- Scrollback
-- =========================

config.scrollback_lines = 10000

-- =========================
-- Cursor
-- =========================

config.default_cursor_style = "BlinkingBlock"

-- =========================
-- Keybindings
-- =========================

config.keys = {

	-- split vertical
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- split horizontal
	{
		key = "d",
		mods = "ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- new tab
	{
		key = "t",
		mods = "CMD",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},

	-- close pane
	{
		key = "w",
		mods = "CMD",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
}

config.hyperlink_rules = wezterm.default_hyperlink_rules()
table.insert(config.hyperlink_rules, {
	regex = [=[\bhttps?://[^\s"'<>]+[^\s"'<>.,;:!?)\]}\*]]=],
	format = "$0",
})

return config
