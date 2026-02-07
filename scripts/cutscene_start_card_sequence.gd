extends Control

var cards = [
	preload("res://n_assets/n_cuts/start/history_s1.png"),
	preload("res://n_assets/n_cuts/start/history_s2.png")
]

var texts = [
"Araci... filha da aurora.
Neta do pajé do Povo Jaguara, guardiã da floresta e dos segredos dos Encantados.
Desde criança, os animais a seguiam, as plantas floresciam ao seu redor, e os espíritos sussurravam em seus sonhos.

O Povo Jaguara vive entre a Mata Atlântica e a Caatinga, onde cada rio é sagrado e cada árvore tem alma.
A natureza não é recurso - é parente, é espírito, é memória viva.",
	
"Nos limites do território, a onça sagrada vigia em silêncio.
Ela é guardiã ancestral, símbolo de força e equilíbrio.
Quando ela se inquieta... os anciãos escutam.

Na noite do Toré, os espíritos da floresta vieram em sonho e sussurraram um chamado.
Um rastro de desequilíbrio se espalha... e Araci deve seguir sua origem.
Você é a aurora que trará novo dia para nosso povo."
]

var left :Vector2 = Vector2(30, 40)
var right :Vector2 = Vector2(300, 30)
var center :Vector2 = Vector2(450, 300)

var positions = [
	right, 
	left
]

var current_index = 0

func _ready():
	show_card(current_index)

func show_card(index):
	# fundo
	$TextureRect.texture = cards[index]
	$ColorRect.modulate = Color(0,0,0,1)

	var tween_bg = create_tween()
	tween_bg.tween_property($ColorRect, "modulate:a", 0.0, 1.0)

	# texto principal
	$Label.text = texts[index]
	$Label.position = positions[index]
	$Label.modulate = Color(0,0,0,0)

	#Texto de instruções
	$Label_instructions.position = Vector2(220,340)
	$Label_instructions.modulate = Color(0,0,0,0)
	
	# fade-in com atraso
	var tween_text = create_tween()
	tween_text.tween_interval(0.5) # atraso de meio segundo
	tween_text.tween_property($Label, "modulate:a", 1.0, 1.0)
	tween_text.tween_property($Label_instructions, "modulate:a", 1.0, 1.0)

func _input(event):
	if event.is_action_pressed("ui_accept"): # espaço
		if current_index < cards.size() - 1:
			current_index += 1
			show_card(current_index)
		else:
			#queue_free()
			start_game()
	elif event.is_action_pressed("ui_cancel"): # esc
		start_game()

func start_game():
	get_tree().change_scene_to_file("res://levels/world_01.tscn")
