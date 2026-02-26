extends TouchScreenButton

func _on_pressed() -> void:
	if Globals.araci:
		Globals.araci.do_superjump()

func _on_released() -> void:
	if Globals.araci:
		Globals.araci.do_superjump()
