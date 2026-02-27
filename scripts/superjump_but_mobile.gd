extends TouchScreenButton

func _on_pressed() -> void:
	if Globals.araci:
		Globals.araci.superjump_held = true
		Globals.araci.jump_requested = true
		Globals.araci.jump_held = true

func _on_released() -> void:
	if Globals.araci:
		Globals.araci.superjump_held = false
		Globals.araci.jump_held = false
