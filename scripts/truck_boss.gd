extends Node2D
@onready var detect_player: Area2D = $detect_player
@onready var wheels: AnimatedSprite2D = $anime

var speed = 20
var player_near = false
var stopped = false   # nova flag para controlar parada definitiva

func _physics_process(delta):
	if player_near and not stopped:
		position.x += speed * delta

func _on_detect_player_body_entered(body):
	print("Andar!")
	if body.is_in_group("player"):
		player_near = true
		if not stopped:   # só gira pneu se não estiver parado
			wheels.play("move")

func _on_detect_player_body_exited(body):
	print("Parar!")
	if body.is_in_group("player"):
		player_near = false
		wheels.stop()

func _on_truck_stop_body_entered(body: Node2D) -> void:
	print("Entrou na área de parada!")
	# caminhão para de qualquer jeito
	stopped = true
	wheels.stop()
