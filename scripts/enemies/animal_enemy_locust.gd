extends CharacterBody2D

@export var animal_name = "gafanhoto"
@onready var anime: AnimatedSprite2D = $anime
@onready var animator: AnimationPlayer = $animator
#Scale speed é tipico apenas das aves, é a velocidade vertical
@export var velocity_scale_speed := 0.3
@export var anime_horizontal := true

@export var speed := 700.0
@export var enemy_score := 100
@export var enemy_life := 1


##Permite integrar à missão de plantar árvores (Estágio 3) - se true indica que quando as árvores forem plantadas, os gafanhotos serão eliminados
@export var inside_in_mission := true

func _ready():
	animator.speed_scale = velocity_scale_speed
	
	if anime_horizontal:
		play_anim("flying2")
	else:
		play_anim("flying1")

func _physics_process(_delta: float) -> void:
	if Globals.eliminate_locust() and inside_in_mission:
		die()
	

func play_anim(anime_name: String) -> void:
	if animator.has_animation(anime_name):
		animator.play(anime_name)
	else:
		print("Animação não encontrada:", anime_name)


func die()->void:
	queue_free()

func stomped():
	pass
