extends CharacterBody2D

#Melhoria de desempenho: Alteração do Physics process de Araci para melhorar o desempenho (Mantive função anterior)
# ============================================================
# CONFIGURAÇÕES DE MOVIMENTO E PULO (EDITÁVEIS NO INSPECTOR)
# ============================================================

## Altura máxima do pulo
@export var jump_height := 120.0
## Fator de multiplicação para o superpulo
@export var superjump_factor := 3

## Tempo até o topo do pulo                 
@export var max_time_to_peak := 0.5            
## Tempo da queda
@export var max_time_to_fall := 0.6

## Velocidade máxima no chão
@export var max_speed := 150.0
## Aceleração horizontal                  
@export var acceleration := 2000.0              
## Desaceleração horizontal
@export var deceleration := 1800.0              
## Bônus de controle no topo do pulo (mais fácil de se mover lateralmente quando está no ar, próximo ao topo do pulo - 80 causa uma alteração discreta).
@export var apex_bonus := 80.0                  

##Tempo para pular da plataforma - adiciona um tempo extra para reação depois que a plataforma cai
@export var coyote_time := 0.12                 # Tempo para pular após sair da plataforma
## Tempo para registrar o pulo antes de tocar o chão
@export var jump_buffer_time := 0.12            

@export var teleport_distance := 64.0   # distância em pixels

@export var teleport_delay := 0.1       # tempo "sumido" antes de reaparecer

##Controle do PET (Feroz)
@export var pet_scene: PackedScene = preload("res://actors/feroz.tscn")
var pet_instance: Node = null
#Feroz na nível 2. Instância já existe, não chamar novo
@onready var feroz_s2: Node2D = get_node_or_null("../feroz")
@onready var whistle: AudioStreamPlayer2D = $whistle
@onready var teleport: AudioStreamPlayer2D = $teleport

#Controle do pulo
var can_jump: bool = true

func disable_jump():
	can_jump = false

func enable_jump():
	can_jump = true
	
#Forçar caminhada (em vez de corrida)
var force_walk: bool = false

func enable_walk():
	force_walk = true

func disable_walk():
	force_walk = false
	
##Assobia para chama o pet
func wistle_to_call():
	whistle.play()

##Som do teletransporte
func teleport_sound():
	teleport.play()

#Paralisar player (fica parado apena na animação de Idle)
var is_paralyzed: bool = false

##Paralisa os movimentos do player
func paralyze_player():
	is_paralyzed = true
	velocity = Vector2.ZERO
	estado = "idle"
	animation.play("idle")
	

##Retorna os movimento do player
func release_player():
	is_paralyzed = false


# ============================================================
# CANCEL WINDOW - Desativa o ataque quando inicia a animação e logo após pula
# ============================================================

var can_cancel := false
var _cancel_window_active := false  # controla se já há um timer rodando
@export var cancel_window := 0.15   ## tempo para cancelar ataque/tiro com pulo ou movimento

# ============================================================
# VARIÁVEIS INTERNAS DE FÍSICA
# ============================================================

var gravity: float = 0.0
var fall_gravity: float = 0.0
var jump_velocity: float = 0.0

var coyote_timer: float = 0.0
var jump_buffer: float = 0.0

# ============================================================
# OUTRAS VARIÁVEIS
# ============================================================

@onready var animation := $anime as AnimatedSprite2D
@onready var remote_transform: RemoteTransform2D = $remote
@onready var ray_right: RayCast2D = $ray_right
@onready var ray_left: RayCast2D = $ray_left
@onready var araci_start_position: Marker2D = $"../araci_start_position"
@onready var curiosity: Area2D = $curiosity


var knockback_vector := Vector2.ZERO

var estado := "idle"
#var time_jump: float = 0.0
var time_shoot: float = 0.0
var cooldown_tiro: float = 0.5

signal player_has_died()

# ============================================================
# DANO, INVENCIBILIDADE E KNOCKBACK
# ============================================================

var invincible: bool = false          # impede dano repetido
var invincible_time: float = 0.4      # tempo de invencibilidade após levar dano
var is_hurt: bool = false             # trava o movimento durante knockback



# ============================================================
# CÁLCULO DE FÍSICA DO PULO
# ============================================================

func _ready() -> void:
	# Gravidade para subir
	gravity = (2.0 * jump_height) / pow(max_time_to_peak, 2.0)
	# Gravidade para cair (um pouco maior, queda mais “pesada”)
	fall_gravity = (2.0 * jump_height) / pow(max_time_to_fall, 2.0)
	# Velocidade inicial do pulo (negativa = para cima)
	jump_velocity = -sqrt(2.0 * gravity * jump_height)
	#Atualiza a instância de Araci em globals
	Globals.araci = self
	
	#Processamento para informações sobre os animais
	curiosity.area_entered.connect(_on_curiosity_area_entered)
	curiosity.area_exited.connect(_on_curiosity_area_exited)
	
# ============================================================
# Funções do PET
# ============================================================
var is_spawning_pet := false   # flag de bloqueio - evita que o pet seja chamado 2x enquanto aguarda após o assovio
#Chama o pet
func spawn_pet():
	if is_spawning_pet: 
		return   # já está em processo de spawn, ignora

	is_spawning_pet = true

	# Assobio
	wistle_to_call()

	# Espera 2 segundos antes de executar
	await get_tree().create_timer(2.0).timeout

	# Cria o pet apenas se ainda não existe
	if pet_instance == null:
		pet_scene = preload("res://actors/feroz.tscn")
		pet_instance = pet_scene.instantiate()
		get_parent().add_child(pet_instance)
		pet_instance.global_position = global_position + Vector2(32, 0)

	is_spawning_pet = false   # libera novamente

##Dispensa o pet
func despawn_pet():
	if pet_instance != null:
		pet_instance.queue_free()
		pet_instance = null

# ============================================================
# ANIMAÇÃO UPGRADE - TOCADA QUANDO OBTEM NOVOS POWERUPS
# ============================================================
@onready var upgrade_sound: AudioStreamPlayer2D = $upgrade_sound

func play_upgrade():
	estado = "upgrade"
	velocity = Vector2.ZERO   # trava movimento
	upgrade_sound.play()
	animation.play("upgrade")

# ============================================================
# LOOP PRINCIPAL DE FÍSICA
# ============================================================

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	# --------------------------------------------------------
	# ESTADOS ESPECIAIS (encerram cedo)
	# --------------------------------------------------------
	if is_paralyzed:
		velocity = Vector2.ZERO
		estado = "idle"
		return _apply_movement()

	if is_hurt or estado == "upgrade":
		velocity = knockback_vector
		return _apply_movement()

	if estado == "pet_attack":
		velocity.x = 0
		return _apply_movement()

	if estado == "read":
		velocity = Vector2.ZERO
		return _apply_movement()

	# --------------------------------------------------------
	# LÓGICA NORMAL DE MOVIMENTO
	# --------------------------------------------------------
	_update_timers(delta, on_floor)
	_handle_jump()
	_apply_gravity(delta)
	_handle_horizontal(delta,on_floor)
	_handle_actions()

	# --------------------------------------------------------
	# MOVE AND SLIDE (UMA VEZ POR FRAME)
	# --------------------------------------------------------
	_apply_movement()

func _update_timers(delta: float, on_floor: bool) -> void:
	if time_shoot > 0.0:
		time_shoot -= delta

	if on_floor:
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer = jump_buffer_time
	else:
		jump_buffer -= delta


func _handle_jump() -> void:
	if jump_buffer > 0.0 and (coyote_timer > 0.0 or can_cancel):
		if Input.is_action_pressed("call_superjump") and Globals.flag_pw_superjump and can_jump:
			var super_height = jump_height * superjump_factor * Globals.superjump_adiction
			var super_velocity = -sqrt(2.0 * gravity * super_height)
			velocity.y = super_velocity
		elif can_jump:
			velocity.y = jump_velocity

		jump_buffer = 0.0
		coyote_timer = 0.0
		estado = "jump"
		#time_jump = 0.1

func _apply_gravity(delta: float) -> void:
	if velocity.y < 0.0 and not Input.is_action_pressed("ui_accept"):
		velocity.y += gravity * 1.5 * delta
	elif velocity.y > 0.0:
		velocity.y += fall_gravity * delta
	else:
		velocity.y += gravity * delta


func _handle_horizontal(delta: float,on_floor: bool) -> void:
	var input_dir := Input.get_axis("ui_left", "ui_right")
	var apex: float = clamp(abs(velocity.y) / 200.0, 0.0, 1.0)
	var apex_speed: float = lerp(apex_bonus, 0.0, apex)

	if estado != "teleport":
		if input_dir != 0.0:
			velocity.x = move_toward(velocity.x, input_dir * (max_speed + apex_speed), acceleration * delta)
			animation.scale.x = input_dir
			curiosity.scale.x = input_dir

			if can_cancel and estado in ["shoot", "atack"]:
				estado = "run"

			if on_floor and estado not in ["shoot", "atack", "hurt", "jump", "pet_attack", "read"]:
				estado = "run"
		else:
			velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
			if on_floor and estado not in ["shoot", "atack", "hurt", "jump", "pet_attack", "read"]:
				estado = "idle"

#func _apply_movement() -> void:
	#move_and_slide()
	#var on_floor := is_on_floor()
#
	#if on_floor and estado == "jump":
		#estado = "run" if abs(velocity.x) > 10.0 else "idle"
#
	#for i in range(get_slide_collision_count()):
		#var collision: KinematicCollision2D = get_slide_collision(i)
		#var collider = collision.get_collider()
		#if collider and collider.has_method("has_collided_with"):
			#collider.has_collided_with(collision, self)
#
	#match estado:
		#"jump": animation.play("jump")
		#"shoot": animation.play("shoot")
		#"atack": animation.play("atack")
		#"run":
			#if force_walk:
				#animation.play("walk")
				#velocity.x *= 0.4
			#else:
				#animation.play("run")
		#"idle": animation.play("idle")
		#"hurt": animation.play("hurt")
		#"pet_attack": animation.play("pet_attack")
		#"teleport": animation.play("teleport")
		#"read": animation.play("read")
	
#Atualizada para realizar o pulo e não parar em cima do inimigo
func _apply_movement() -> void:
	move_and_slide()
	var on_floor := is_on_floor()
	if on_floor and estado == "jump":
		estado = "run" if abs(velocity.x) > 10.0 else "idle"

	for i in range(get_slide_collision_count()):
		var collision: KinematicCollision2D = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider and collider.is_in_group("enemies"):
			var push_dir = sign(global_position.x - collider.global_position.x)
			if push_dir == 0: push_dir = 1
			velocity.y = jump_velocity * 0.6
			velocity.x = push_dir * max_speed
			if not invincible:
				take_damage(_make_knockback_vector(collider.global_position))
			continue

		if collider and collider.has_method("has_collided_with"):
			collider.has_collided_with(collision, self)

	match estado:
		"jump": animation.play("jump")
		"shoot": animation.play("shoot")
		"atack": animation.play("atack")
		"run":
			if force_walk:
				animation.play("walk")
				velocity.x *= 0.4
			else:
				animation.play("run")
		"idle": animation.play("idle")
		"hurt": animation.play("hurt")
		"pet_attack": animation.play("pet_attack")
		"teleport": animation.play("teleport")
		"read": animation.play("read")

func _handle_actions() -> void:
	if Input.is_action_just_pressed("shoot") and time_shoot <= 0.0:
		estado = "shoot"
		time_shoot = cooldown_tiro
		_start_cancel_window()

	if Input.is_action_just_pressed("atack") and time_shoot <= 0.0:
		estado = "atack"
		time_shoot = cooldown_tiro
		_start_cancel_window()

	if Input.is_action_just_pressed("call_feroz") and !is_instance_valid(feroz_s2):
		#if pet_instance == null and Globals.flag_pw_feroz_enable:
			#spawn_pet()
		#else:
			#despawn_pet()
		# feroz_s2 é o feroz já existente na cena (nível 2)
		# se ele existe, não faz nada pois já está ativo
		if is_instance_valid(feroz_s2):
			return
		if Globals.flag_pw_feroz_enable:
			if pet_instance == null:
				spawn_pet()
			else:
				despawn_pet()

	if Input.is_action_just_pressed("feroz_companion_attack"):
		estado = "pet_attack"
		_start_cancel_window()

	if Input.is_action_just_pressed("teleport") and Globals.flag_pw_teletransport:
		estado = "teleport"
		_teleport()



# ============================================================
# CANCEL WINDOW - Cancela o tiro quando pula
# ============================================================

func _start_cancel_window() -> void:
	can_cancel = true
	if _cancel_window_active:
		return  # já tem um timer rodando, não cria outro
	_cancel_window_active = true
	await get_tree().create_timer(cancel_window).timeout
	can_cancel = false
	_cancel_window_active = false


# ============================================================
#DANO, KNOCKBACK E INVENCIBILIDADE (AJUSTADO)
# ============================================================
@onready var hurt_sound: AudioStreamPlayer2D = $hurt_sound
var knockback_force_normalize = 700
var knockback_force_limit = 750

@export var knockback_force_x := 600.0
@export var knockback_force_y := -350.0

var _damage_tween: Tween = null

#Faz um vetor padrão de knockback baseado nos valores de knockback_force_x e knockback_force_y
func _make_knockback_vector(from_position: Vector2) -> Vector2:
	var dir = sign(global_position.x - from_position.x)
	return Vector2(knockback_force_x * dir, knockback_force_y)

func take_damage(knockback_force := Vector2.ZERO, duration := 0.25) -> void:
	print("Aplicou o take_damage")
	# Se já está invencível, não perde vida, mas ainda aplica knockback
	if invincible:
		if knockback_force != Vector2.ZERO:
			knockback_vector = _apply_knockback_normalize(knockback_force)
		return

	Globals.stat_die_number += 1

	invincible = true
	is_hurt = true
	estado = "hurt"
	
	# Som do dano
	if hurt_sound.stream:
		hurt_sound.volume_db = 0
		hurt_sound.play()

	# Reduz vida
	if Globals.get_life() > 1:
		Globals.loss_of_life()
	else:
		queue_free()
		emit_signal("player_has_died")

	knockback_vector = _apply_knockback_normalize(knockback_force)

	# Cancela tween anterior se existir
	if _damage_tween and _damage_tween.is_running():
		_damage_tween.kill()

	_damage_tween = get_tree().create_tween()
	_damage_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)

	animation.modulate = Color(1, 0, 0)
	_damage_tween.tween_method(
		func(t: float): animation.modulate = Color(1, t, t, 1),
		0.0, 1.0, 0.5
	)

	# Espera o knockback acabar
	await get_tree().create_timer(duration).timeout
	is_hurt = false

	# Volta ao estado correto
	if is_on_floor():
		estado = "run" if abs(velocity.x) > 10 else "idle"
	else:
		estado = "jump"

	# Espera invencibilidade acabar
	await get_tree().create_timer(invincible_time).timeout
	invincible = false

##Versão antiga - Araci consegue ficar em cima dos inimigos
#func take_damage(knockback_force := Vector2.ZERO, duration := 0.25) -> void:
	## evita dano repetido
	#if invincible:
		#return
#
	#Globals.stat_die_number += 1
#
	#invincible = true
	#is_hurt = true
	#estado = "hurt"
	#
	############# Som do dano ################
	#if hurt_sound.stream:
		#print("Deve tocar o som!")	
		#hurt_sound.volume_db = 0
		#hurt_sound.play()
	#else:
		#print("Nenhum stream configurado em $hurt_sound")
	#
	##print("Chamou take damage, deveria mudar de cor")
	## reduz vida
	#if Globals.get_life() > 1:
		#Globals.loss_of_life()
		##print("Take Damage:"+str(Globals.get_life()))
	#else:
		#queue_free()
		#emit_signal("player_has_died")
	#
	##normaliza e limita knockback
	#if knockback_force != Vector2.ZERO:
		#knockback_force = knockback_force.normalized() * 300  # valor fixo
		#knockback_force = knockback_force.limit_length(400)   # limite máximo - Evita que o jogador seja projetado para muito longe
		#
	## aplica knockback
	#knockback_vector = knockback_force
#
	## Tween para suavizar knockback e piscada
	#var tween: Tween = get_tree().create_tween()
#
	## Knockback suaviza em paralelo
	#tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
#
	## Cor: primeiro vermelho, depois branco (sequencial)
	#animation.modulate = Color(1, 0, 0) # já começa vermelho
	#tween.tween_property(animation, "modulate", Color(1, 1, 1), 0.1)
	#tween.tween_property(animation, "modulate", Color(1, 0, 0), 0.1)
	#tween.tween_property(animation, "modulate", Color(1, 1, 1), 0.1)
	#tween.tween_property(animation, "modulate", Color(1, 0, 0), 0.1) # piscada extra
	#tween.tween_property(animation, "modulate", Color(1, 1, 1), 0.1) # volta ao normal
#
	##espera o knockback acabar
	#await get_tree().create_timer(duration).timeout
	#is_hurt = false
#
	##volta ao estado correto
	#if is_on_floor():
		#if abs(velocity.x) > 10:
			#estado = "run"
		#else:
			#estado = "idle"
	#else:
		#estado = "jump"
#
	##espera invencibilidade acabar
	#await get_tree().create_timer(invincible_time).timeout
	#invincible = false

# ============================================================
# OUTROS
# ============================================================

func handle_death_zone() -> void:
	#if Globals.player_life >= 0:
	if Globals.get_life() > 0:
		if Globals.get_life() > 1:
			Globals.loss_of_life()
			Globals.stat_die_number += 1
		else:
			Globals.stat_die_number += 1
			Globals.stat_colectable_lifes = 3
			Globals.reset_life()
			
		visible = false
		set_physics_process(false)
		await get_tree().create_timer(1.0).timeout
		Globals.respaw_player()
		visible = true
		set_physics_process(true)
	else:
		visible = false
		await get_tree().create_timer(0.5).timeout

func follow_camera(camera: Node2D) -> void:
	remote_transform.remote_path = camera.get_path()

func _on_anime_animation_finished() -> void:
	if estado in ["shoot", "atack", "pet_attack", "teleport", "upgrade", "read"]:
		var input_dir := Input.get_axis("ui_left", "ui_right")
		if input_dir != 0 and is_on_floor():
			estado = "run"
		else:
			estado = "idle"

func _on_hurtbox_body_entered(body: Node2D) -> void:
		#print("Araci levou dano") 
		take_damage(_make_knockback_vector(body.global_position))

#Requer configuração dos grupos (Permite dano quando em uma área especificada em groups
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Se a área for uma armadilha recorrente
	#Quando tem armadilhas de dano recorrente (não desarmam)
	#Quando a armadilha desarma após o primeiro dano o script que controla o dano é no script da armadilha
	if area.is_in_group("appellant traps"):
		take_damage(_make_knockback_vector(area.global_position))



func _teleport():
	var dir = sign(animation.scale.x)
	if dir == 0:
		dir = 1

	var target_pos = global_position + Vector2(teleport_distance * Globals.teleport_distance_adiction * dir, 0)

	var space_state = get_world_2d().direct_space_state

	# Usar um pequeno círculo para checar espaço alvo
	var shape = CircleShape2D.new()
	shape.radius = 4.0

	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, target_pos)
	params.exclude = [self]
	params.collide_with_bodies = true
	params.collide_with_areas = true   # ignora áreas de detecção
	params.collision_mask = (1 << 4) | (1 << 5) | (1 << 8)  # camadas 5, 6 e 9

	var result = space_state.intersect_shape(params)

	if result.is_empty():
		teleport_sound()
		visible = false
		await get_tree().create_timer(teleport_delay).timeout
		global_position = target_pos
		velocity.x = 0
		visible = true
	else:
		print("Teleport cancelado: destino bloqueado")
		# Debug para ver quem está bloqueando
		for r in result:
			var collider = r.collider
			if collider is PhysicsBody2D or collider is Area2D:
				print("Colidiu com:", collider.name, "camada:", collider.collision_layer)
			else:
				print("Colidiu com:", collider.name, "(sem collision_layer)")

	# Ajusta estado
	if is_on_floor():
		estado = "run" if abs(velocity.x) > 10 else "idle"
	else:
		estado = "jump"


############ INFORMAÇÕES DOS ANIMAIS ######################
#A lógica de informações dos animais foi centralizada em Araci, os animais requerem uma variável script
#associada a uma characterBody2d contendo uma aux_area marcada como ly_info (deve colidir com curiosity).
#Lembrar de colocar os animais no grupo animals (a função requer isso)
var default_icon_animals_info = "res://n_assets/n_scenes/elements/book_icon.png"
var red_icon_animals_info = "res://n_assets/n_scenes/elements/red_page_book_icon.png"
var green_icon_animals_info = "res://n_assets/n_scenes/elements/green_page_book_icon.png"
#Biblioteca de informações
var animals_info := {
	"arara azul": {
		"descricao": "Arara azul da Mata Atlântica, nativa e símbolo vibrante da biodiversidade.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"boi": {
		"descricao": "Boi, espécie exótica introduzida, importante na pecuária brasileira.",
		"icone": red_icon_animals_info,
		"tempo": 5.0
	},
	"caramujo africano": {
		"descricao": "Caramujo africano, espécie exótica invasora que ameaça ecossistemas locais.",
		"icone": red_icon_animals_info,
		"tempo": 5.0
	},
	"cobra coral verdadeira": {
		"descricao": "Cobra coral verdadeira, nativa da Mata Atlântica, venenosa e colorida.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"gafanhoto": {
		#"descricao": "Gafanhoto, inseto nativo, essencial no equilíbrio ecológico da Caatinga e Mata Atlântica.",
		"descricao": "Em enxames, os gafanhotos, devastam lavouras e exigem controle químico ou biológico.",
		"icone": red_icon_animals_info,
		"tempo": 5.0
	},
	"gralha cancão": {
		"descricao": "Gralha cancão, ave nativa da Caatinga, conhecida pelo canto forte e marcante.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"javali": {
		"descricao": "Javali, espécie exótica invasora, ameaça cultivos e fauna nativa brasileira.",
		"icone": red_icon_animals_info,
		"tempo": 5.0
	},
	"macuco": {
		"descricao": "Macuco, ave nativa da Mata Atlântica, discreta e habitante do sub-bosque.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"mainá": {
		"descricao": "Mainá, ave exótica introduzida, adaptada a áreas urbanas e agrícolas.",
		"icone": red_icon_animals_info,
		"tempo": 5.0
	},
	"onça pintada": {
		"descricao": "Onça pintada, nativa da Mata Atlântica, maior felino das Américas e predador de topo.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"raposa da caatinga": {
		"descricao": "Cachorro-do-mato, ou Raposa da Caatinga é nativa, ágil e adaptada ao clima semiárido do Nordeste.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"rolinha caldo de feijão": {
		"descricao": "Rolinha caldo de feijão, ave nativa, comum em áreas abertas da Caatinga.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"sabiá de laranjeira": {
		"descricao": "Sabiá de laranjeira, nativa da Mata Atlântica, ave símbolo do Brasil.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"saira sete cores": {
		"descricao": "Saíra sete cores, nativa da Mata Atlântica, famosa pela plumagem vibrante.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"tamanduá-bandeira": {
		"descricao": "Tamanduá-bandeira, nativo da Mata Atlântica e Caatinga, especialista em formigas.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"tatú-peba": {
		"descricao": "Tatú-peba, nativo da Caatinga, escavador ágil com carapaça resistente.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"teiu": {
		"descricao": "Teiú, lagarto nativo da Caatinga e Mata Atlântica, robusto e onívoro.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"tie sangue": {
		"descricao": "Tiê-sangue, nativo da Mata Atlântica, ave de plumagem vermelha intensa.",
		"icone": green_icon_animals_info,
		"tempo": 5.0
	},
	"rato doméstico": {
	"descricao": "Rato doméstico, pequeno roedor urbano, adaptável e associado a ambientes humanos.",
	"icone": red_icon_animals_info,
	"tempo": 3.0
	},
	"pombo": {
	"descricao": "Pombos-domésticos, são considerados uma praga urbana, um risco à saúde pública",
	"icone": red_icon_animals_info,
	"tempo": 3.0
	},
	"pardal": {
	"descricao": "O pardal é uma ave exótica invasora que ameaça a biodiversidade da Mata Atlântica.",
	"icone": red_icon_animals_info,
	"tempo": 5.0
	}
}

var current_animal_name: String = ""   # guarda o nome do animal mais próximo
var is_showing_message := false #Fag de uma trava para o botão enquanto uma mensagem aparece

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and current_animal_name != "" and not is_showing_message:
		var info = animals_info.get(current_animal_name, null)
		if info != null:
			var icon = load(info["icone"])
			is_showing_message = true
			Globals.show_side_mensage(info["descricao"], icon, info["tempo"])
			
			if is_on_floor():#Só toca a animação de ler se estiver no chão
				#Ajuste: toca a animação de leitura
				estado = "read"
				velocity = Vector2.ZERO   # trava movimento enquanto lê
				#animation.play("read")
				
			# libera o botão depois que o tempo da mensagem passar
			await get_tree().create_timer(info["tempo"]).timeout
			is_showing_message = false

# Quando a mensagem terminar reativa a  ação do botão i
func _on_message_finished():
	is_showing_message = false
	estado = "idle"

func _on_curiosity_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.is_in_group("animals") and "animal_name" in parent:
		current_animal_name = parent.animal_name.to_lower()
		#print("Araci está perto de:", current_animal_name)

func _on_curiosity_area_exited(area: Area2D) -> void:
	var parent = area.get_parent()
	if "animal_name" in parent and parent.is_in_group("animals") and parent.animal_name.to_lower() == current_animal_name:
		current_animal_name = ""
		#print("Araci se afastou do animal")


##Falas em balão

@onready var speech_bubble: Node2D = $speech_bubble

##Permite a exibição de falas em um balão
func say(text: String, time: float):
	speech_bubble.show_message(text, time)

##Normaliza o valor do knockback
func _apply_knockback_normalize(force: Vector2) -> Vector2:
	if force == Vector2.ZERO:
		return Vector2.ZERO
	return force.normalized() * knockback_force_normalize
