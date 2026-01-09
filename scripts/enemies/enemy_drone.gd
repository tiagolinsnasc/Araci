extends Node2D

@onready var anime: AnimatedSprite2D = $anime
@onready var damage_area: Area2D = $damage_area
@onready var detect_area: Area2D = $detect_area
@onready var cooldown_timer: Timer = $attack_timer   # Timer como filho do drone

@export var attack_interval := 5.0
@export var max_attack_distance := 900.0   # distância máxima para cancelar ataque

var origin_position: Vector2
var target: Node2D = null
var speed: float = 120.0

var is_attacking_cycle: bool = false

func _ready():
	origin_position = global_position
	cooldown_timer.wait_time = attack_interval
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_cooldown_timeout)

func _on_detect_area_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox" and not is_attacking_cycle:
		target = area.get_parent()
		if target:
			_start_attack_cycle()

func _on_detect_area_area_exited(area: Area2D) -> void:
	if area.name == "hurtbox":
		target = null
		cooldown_timer.stop()
		is_attacking_cycle = false
		damage_area.monitoring = false
		await _return_to_origin()

func _physics_process(delta: float) -> void:
	if is_attacking_cycle and target:
		# ✅ cancela ataque se distância for maior que limite
		if global_position.distance_to(target.global_position) > max_attack_distance:
			is_attacking_cycle = false
			damage_area.monitoring = false
			cooldown_timer.stop()
			await _return_to_origin()
			return

		# movimento normal em direção ao player
		global_position = global_position.move_toward(target.global_position, speed * delta)

func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox" and is_attacking_cycle:
		var player = area.get_parent()
		if player.has_method("take_damage"):
			var direction_jump: float = sign(player.global_position.x - global_position.x)
			var knockback: Vector2 = Vector2(600 * direction_jump, -350)
			player.take_damage(knockback)

		anime.play("shake")
		await anime.animation_finished
		anime.play("fly")

		# encerra ciclo e retorna
		await _return_to_origin()
		is_attacking_cycle = false
		damage_area.monitoring = false

		# inicia cooldown se player ainda estiver na área
		if target:
			cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	# após o intervalo, se player ainda está na área, inicia novo ataque
	if target and not is_attacking_cycle:
		_start_attack_cycle()

func _start_attack_cycle() -> void:
	if not target:
		return
	is_attacking_cycle = true
	damage_area.monitoring = true
	anime.play("fly")

func _return_to_origin() -> void:
	var tween = create_tween()
	tween.tween_property(self, "global_position", origin_position, 1.5)
	await tween.finished
	anime.play("fly")
