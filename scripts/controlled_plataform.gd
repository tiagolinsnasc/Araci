extends Node2D

const WAIT_DURATION := 1.0

@onready var plataform: AnimatableBody2D = $plataform
@export var move_speed := 3.0
@export var distance := 192
@export var move_horizontal := true

var follow = Vector2.ZERO
var plataform_center := 16
var is_active := false

func _ready() -> void:
	# não inicia sozinho
	pass

func _physics_process(_delta: float) -> void:
	if is_active:
		plataform.position = plataform.position.lerp(follow, 0.5)

## Ativar o movimento da plataforma (uma vez)
func activate() -> void:
	if not is_active:
		is_active = true
		await move_plataform()
		is_active = false  # libera para nova ativação

func move_plataform() -> void:
	var move_direction = Vector2.RIGHT * distance if move_horizontal else Vector2.UP * distance
	var duration = move_direction.length() / float(move_speed * plataform_center)

	var plataform_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	plataform_tween.tween_property(self, "follow", move_direction, duration).set_delay(WAIT_DURATION)
	await plataform_tween.finished

	var return_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	return_tween.tween_property(self, "follow", Vector2.ZERO, duration).set_delay(WAIT_DURATION * 2.0)
	await return_tween.finished
