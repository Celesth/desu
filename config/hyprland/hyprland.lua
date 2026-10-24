local MAIN = "SUPER"
local TERMINAL = os.getenv("TERMINAL") or "kitty"

local function command(value)
	return hl.dsp.exec_cmd(value)
end

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

hl.env("TERMINAL", TERMINAL)
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.on("hyprland.start", function()
	hl.exec_cmd("desu start")
	hl.exec_cmd("pgrep -x awww-daemon >/dev/null 2>&1 || (awww-daemon >/dev/null 2>&1 &)")
	hl.exec_cmd("sleep 1 && desu wallpaper restore >/dev/null 2>&1 || true")
end)

hl.bind(MAIN .. " + SUPER_L", command("desu launcher"), {
	release = true,
	description = "Open DESU launcher",
})
hl.bind(MAIN .. " + SUPER_R", command("desu launcher"), {
	release = true,
	description = "Open DESU launcher",
})

hl.bind(MAIN .. " + RETURN", command(TERMINAL), { description = "Open terminal" })
hl.bind(MAIN .. " + SHIFT + D", command("desu launcher actions"), {
	description = "Open DESU actions",
})
hl.bind(MAIN .. " + C", command("desu clipboard"), { description = "Open clipboard history" })
hl.bind(MAIN .. " + W", command("desu wallpaper select"), { description = "Open wallpaper selector" })
hl.bind(MAIN .. " + R", command("desu recorder toggle"), { description = "Toggle screen recorder" })
hl.bind(MAIN .. " + A", command("desu audio"), { description = "Open audio mixer" })
hl.bind(MAIN .. " + N", command("desu ipc call desu notificationToggle"), {
	description = "Toggle notifications",
})
hl.bind(MAIN .. " + SHIFT + S", command("desu screenshot region"), {
	description = "Take a screenshot",
})
hl.bind(MAIN .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(MAIN .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), {
	description = "Toggle fullscreen",
})
hl.bind(MAIN .. " + SPACE", hl.dsp.window.float({ action = "toggle" }), {
	description = "Toggle floating",
})

hl.bind(MAIN .. " + Left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(MAIN .. " + Right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(MAIN .. " + Up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(MAIN .. " + Down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
hl.bind(MAIN .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }), {
	description = "Move window left",
})
hl.bind(MAIN .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), {
	description = "Move window right",
})
hl.bind(MAIN .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }), {
	description = "Move window up",
})
hl.bind(MAIN .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }), {
	description = "Move window down",
})

hl.bind(MAIN .. " + mouse_down", hl.dsp.focus({ workspace = "r-1" }), {
	description = "Previous workspace",
})
hl.bind(MAIN .. " + mouse_up", hl.dsp.focus({ workspace = "r+1" }), {
	description = "Next workspace",
})

for index = 1, 10 do
	local key = index % 10
	hl.bind(MAIN .. " + " .. key, command("hyprctl dispatch workspace " .. index), {
		description = "Switch to workspace " .. index,
	})
	hl.bind(MAIN .. " + SHIFT + " .. key, command("hyprctl dispatch movetoworkspacesilent " .. index), {
		description = "Move window to workspace " .. index,
	})
end

hl.bind("XF86AudioRaiseVolume", command("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86AudioLowerVolume", command("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86AudioMute", command("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.window_rule({ name = "desu_pavucontrol_float", match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" }, float = true })
hl.window_rule({ name = "desu_pavucontrol_size", match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" }, size = "45% 45%" })
hl.window_rule({ name = "desu_pavucontrol_center", match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol)$" }, center = true })
