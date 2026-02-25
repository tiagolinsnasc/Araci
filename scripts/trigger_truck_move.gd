extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
#Caminhão 1
@onready var anime: AnimatedSprite2D = $"../../machines/machine_truck_traveler/machine_area/anime"
@onready var animation: AnimationPlayer = $"../../machines/machine_truck_traveler/animation"

#Caminhão 2
@onready var anime2: AnimatedSprite2D = $"../../machines/machine_truck_traveler2/machine_area/anime"
@onready var animation2: AnimationPlayer = $"../../machines/machine_truck_traveler2/animation"

var active = true

func _on_body_entered(body: Node2D) -> void:
	if Globals.is_player(body) and active:
		print("Gatilho ativo")
		anime.play("move_loaded")
		animation.play("move")
		
		# espera 2 segundos
		await get_tree().create_timer(2.0).timeout
		
		anime2.play("move_loaded")
		animation2.play("move")
		active = false
