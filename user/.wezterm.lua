local wezterm = require("wezterm")

local config = wezterm.config_builder()

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
config.use_fancy_tab_bar = true

config.window_frame = {
	font_size = 14.0,
	active_titlebar_bg = "#181825",
	inactive_titlebar_bg = "#181825",
}

config.colors = {
	tab_bar = {
		background = "#181825",
		active_tab = {
			bg_color = "#1e1e2e",
			fg_color = "#cdd6f4",
		},
		inactive_tab = {
			bg_color = "#181825",
			fg_color = "#6c7086",
		},
		inactive_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
		new_tab = {
			bg_color = "#181825",
			fg_color = "#6c7086",
		},
		new_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
	},
}

-- =========================
-- Notifications
-- =========================

config.audible_bell = "Disabled"

wezterm.on("bell", function(window, pane)
	local msg = pane:get_user_vars().claude_status or "Claude Code"

	local dominated = false
	if window:is_focused() then
			local tab = pane:tab()
			local active_tab = window:mux_window():active_tab()
			if tab and active_tab and active_tab:tab_id() == tab:tab_id() then
				dominated = true
			end
	end

	if not dominated then
		window:toast_notification("Claude Code", msg, nil, 4000)
		wezterm.background_child_process({
			"afplay", "/System/Library/Sounds/Glass.aiff",
		})
	end
end)

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
