extends Area2D

#Habilita feroz
func _on_body_entered(body: Node2D) -> void:
	if Globals.is_player(body):
		#print("Feroz disponível")
		Globals.pw_feroz_enabled()
