#Genérico, sereve para qualquer animal preso em armadilhas
extends Node2D
@export var score := 100

func _ready() -> void:
	Globals.stat_disponible_animal_traps += 1
	Globals.stat_disponible_score =+ score

func _on_area_body_entered(body: Node2D) -> void:
	if Globals.is_player(body):
		Globals.give_points_to_player(score,global_position,self)
		Globals.stat_saved_animals_traps += 1
		queue_free()
	if not Globals.flag_grab_one_animal_in_trap:
		Globals.show_side_mensage("Você libertou um animal de uma armadilha! Ganhou pontos!",null, 5.0)
		Globals.flag_grab_one_animal_in_trap = true
		
		
