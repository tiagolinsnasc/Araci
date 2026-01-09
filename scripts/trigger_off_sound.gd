extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Araci" and Globals.is_ambient_playing():
		print("Deligar som ambiente!")
		Globals.stop_ambient_sound()
	elif body.name == "Araci" and not Globals.is_ambient_playing():
		var world = get_tree().current_scene
		var stage = world.stage_number
		var ambient_stream = Globals.stage_sounds.get(stage, null)
		print("Ligar som ambiente!")
		Globals.play_ambient(ambient_stream)
