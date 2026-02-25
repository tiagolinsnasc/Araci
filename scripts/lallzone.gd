extends Area2D


func _on_body_entered(body: Node2D) -> void:
	#print("Caiu....")
	if Globals.is_player(body):
		body.handle_death_zone()
