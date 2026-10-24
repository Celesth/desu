local terminal = os.getenv("TERMINAL") or "kitty"

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 6,
		border_size = 1,
		layout = "dwindle",
		allow_tearing = false,
	},
	decoration = {
		rounding = 0,
		blur = { enabled = false },
		shadow = { enabled = false },
	},
	input = {
		kb_layout = "us",
		numlock_by_default = true,
		follow_mouse = 1,
	},
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
		background_color = "rgb(202020)",
	},
	xwayland = {
		enabled = true,
		force_zero_scaling = true,
	},
})

hl.env("TERMINAL", terminal)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
