local pavucontrol_class = "^(pavucontrol|org.pulseaudio.pavucontrol)$"

hl.window_rule({
	name = "desu_pavucontrol_float",
	match = { class = pavucontrol_class },
	float = true,
})
hl.window_rule({
	name = "desu_pavucontrol_size",
	match = { class = pavucontrol_class },
	size = "45% 45%",
})
hl.window_rule({
	name = "desu_pavucontrol_center",
	match = { class = pavucontrol_class },
	center = true,
})
