local main = "SUPER"
local terminal = os.getenv("TERMINAL") or "kitty"

local function command(value)
	return hl.dsp.exec_cmd(value)
end

hl.bind(main .. " + SUPER_L", command("desu launcher"), {
	release = true,
	description = "Open DESU launcher",
})
hl.bind(main .. " + SUPER_R", command("desu launcher"), {
	release = true,
	description = "Open DESU launcher",
})

hl.bind(main .. " + RETURN", command(terminal), { description = "Open terminal" })
hl.bind(main .. " + SHIFT + D", command("desu launcher actions"), {
	description = "Open DESU actions",
})
hl.bind(main .. " + V", command("desu clipboard"), { description = "Open clipboard history" })
hl.bind(main .. " + W", command("desu wallpaper select"), { description = "Open wallpaper selector" })
hl.bind(main .. " + CTRL + T", command("desu wallpaper select"), { description = "Open wallpaper selector" })
hl.bind(main .. " + R", command("desu recorder toggle"), { description = "Toggle screen recorder" })
hl.bind(main .. " + A", command("desu audio"), { description = "Open audio mixer" })
hl.bind(main .. " + N", command("desu ipc call desu notificationToggle"), {
	description = "Toggle notifications",
})
hl.bind(main .. " + SHIFT + S", command("desu screenshot region"), {
	description = "Take a screenshot",
})
hl.bind(main .. " + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind(main .. " + SHIFT + K", hl.dsp.window.close(), { description = "Terminate focused window" })
hl.bind(main .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }), {
	description = "Toggle fullscreen",
})
hl.bind(main .. " + SPACE", hl.dsp.window.float({ action = "toggle" }), {
	description = "Toggle floating",
})

hl.bind(main .. " + Left", hl.dsp.focus({ direction = "left" }), { description = "Focus left" })
hl.bind(main .. " + Right", hl.dsp.focus({ direction = "right" }), { description = "Focus right" })
hl.bind(main .. " + Up", hl.dsp.focus({ direction = "up" }), { description = "Focus up" })
hl.bind(main .. " + Down", hl.dsp.focus({ direction = "down" }), { description = "Focus down" })
hl.bind(main .. " + SHIFT + Left", hl.dsp.window.move({ direction = "l" }), {
	description = "Move window left",
})
hl.bind(main .. " + SHIFT + Right", hl.dsp.window.move({ direction = "r" }), {
	description = "Move window right",
})
hl.bind(main .. " + SHIFT + Up", hl.dsp.window.move({ direction = "u" }), {
	description = "Move window up",
})
hl.bind(main .. " + SHIFT + Down", hl.dsp.window.move({ direction = "d" }), {
	description = "Move window down",
})

hl.bind(main .. " + mouse_up", hl.dsp.focus({ workspace = "r-1" }), {
	description = "Previous workspace",
})
hl.bind(main .. " + mouse_down", hl.dsp.focus({ workspace = "r+1" }), {
	description = "Next workspace",
})
hl.bind(main .. " + ALT + mouse_up", hl.dsp.window.move({ workspace = "r-1" }), {
	description = "Move window to previous workspace",
})
hl.bind(main .. " + ALT + mouse_down", hl.dsp.window.move({ workspace = "r+1" }), {
	description = "Move window to next workspace",
})
hl.bind(main .. " + mouse:272", hl.dsp.window.drag(), {
	mouse = true,
	description = "Move window with mouse",
})

for index = 1, 10 do
	local key = index % 10
	hl.bind(main .. " + " .. key, command("hyprctl dispatch workspace " .. index), {
		description = "Switch to workspace " .. index,
	})
	hl.bind(main .. " + SHIFT + " .. key, command("hyprctl dispatch movetoworkspacesilent " .. index), {
		description = "Move window to workspace " .. index,
	})
	hl.bind(main .. " + KP_" .. key, command("hyprctl dispatch workspace " .. index), {
		description = "Switch to workspace " .. index .. " with keypad",
	})
	hl.bind(main .. " + SHIFT + KP_" .. key, command("hyprctl dispatch movetoworkspacesilent " .. index), {
		description = "Move window to workspace " .. index .. " with keypad",
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
