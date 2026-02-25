extends TouchScreenButton


func _on_pressed() -> void:
	# Simula os dois inputs juntos
	Input.action_press("ui_accept")          # pulo
	Input.action_press("call_superjump")     # superpulo
	

func _on_released() -> void:
	# Simula os dois inputs juntos
	Input.action_press("ui_accept")          # pulo
	Input.action_press("call_superjump")     # superpulo
