extends Area2D


#Imagem da porção vermelha
var poison_image := preload("res://n_assets/n_scenes/elements/red_poison_icon.png")

func _on_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	#print("Araci coletou!")
	$anime.play("collect")
	await $CollisionShape2D.call_deferred("queue_free") #Espera a colisão acabar (impede que o item seja coletado duas vezes)
	Globals.show_side_mensage("Você ganhou o poder do teleport! Pressione T para se teletransportar.",poison_image,8.0)
	Globals.pw_teleport_enabled()
	Globals.araci.play_upgrade()



func _on_anime_animation_finished() -> void:
	queue_free()
