extends Area2D

var flag_on = true

func _on_body_entered(body: Node2D) -> void:
	if Globals.is_player(body):
		if flag_on and is_instance_valid(Globals.hud):
			Globals.hud.show_notification(
				"Pressione as setas direcionais para ir para frente ou para trás. Use a barra de espaço para pular.",
				null,
				7.0
			)
			flag_on = false
