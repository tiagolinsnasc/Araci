extends Area2D
#Poder do Teletransporte

#Imagem da porção vermelha
var poison_image := preload("res://n_assets/n_scenes/elements/red_poison_icon.png")


func _on_anime_animation_finished() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if Globals.is_player(body):
		#print("Araci coletou!")
		$anime.play("collect")
		await $CollisionShape2D.call_deferred("queue_free") #Espera a colisão acabar (impede que o item seja coletado duas vezes)
		Globals.show_side_mensage("Você ganhou o poder do teleport! Pressione T para se teletransportar.",poison_image,8.0)
		Globals.pw_teleport_enabled()
		Globals.araci.play_upgrade()
