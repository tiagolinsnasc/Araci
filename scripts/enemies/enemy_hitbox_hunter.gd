extends Area2D
#Compartilhado entre atiradores
#Script do hitbox - causar dano no player
func _on_body_entered(body: Node2D) -> void:
		if Globals.is_player(body) && body.has_method("take_damage"):
			#print("Sofreu dano do caçador!")
			#Dano diferenciado (proveniente de tiro) - não pula apenas fica vermelha
			body.take_damage(Vector2(0,-250)) 
