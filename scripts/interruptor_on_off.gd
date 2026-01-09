extends Area2D

@onready var anime: AnimatedSprite2D = $anime
@onready var controlled_plataform: Node2D = $"../controlled_plataform"
@export var off_timer = 3.0 #Tempo para alternar entro os botões
@export var start_action_timer = 4.0 #Tempo iniciar o resultado da alavanca

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Araci":
		anime.play("on")
		await get_tree().create_timer(start_action_timer).timeout
		controlled_plataform.activate()
		await get_tree().create_timer(off_timer).timeout
		anime.play("off")
