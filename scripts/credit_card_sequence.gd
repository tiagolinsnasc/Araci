extends Control

@onready var logo_ufal: Sprite2D = $logoUfal
@onready var logo_profbio: Sprite2D = $logoProfbio

var cards = [
	preload("res://n_assets/n_cuts/start/credit_bg.png"),
	#preload("res://n_assets/n_cuts/final/s2.png"),
]

var texts = [
	"[center][b]ARACI: UMA JORNADA DE RESISTÊNCIA E RENOVAÇÃO[/b][/center]
	
	[b]Desenvolvedor:[/b]  Thiago Lins do Nascimento
		
	Este jogo faz parte do recurso educacional produzido a partir da dissertação \"Construção de narrativas e produção de um jogo digital para ensino de ecologia\" do Mestrado Profissional em Ensino de Biologia em Rede Nacional - ProfBio - Universidade Federal de Alagoas. 
	
	[b]Mestrando:[/b] Thiago Lins do Nascimento.
	[b]Orientador:[/b]Prof. Dr. Marcos Vinícius Carneiro Vital.

	[b]Histórias iniciais:[/b] Colaboração da turma do 1º ANO A do curso técnico de Redes de Computadores do Ensino Médio da ETE Francisco de Matos Sobrinho (2025)
	
	[b]Plataforma de desenvolvimento:[/b] Godot 4.5.1 no Linux Mint 22.2 Cinnamon
	",
	
	#"Narrativa principal: Thiago Lins do Nascimento
	#Histórias iniciais: Turma do 1º ANO do Ensino Médio da ETE Francisco de Matos Sobrinho"
]


var left :Vector2 = Vector2(40, 40)
var right :Vector2 = Vector2(300, 40)
var center :Vector2 = Vector2(20, 20)#Ajuste próprio, alinhado à esquerda no topo

var positions = [
	center, 
	#left
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
	$Label_instructions.position = Vector2(260,340)
	$Label_instructions.modulate = Color(0,0,0,0)
	
	# fade-in com atraso
	var tween_text = create_tween()
	tween_text.tween_interval(0.5) # atraso de meio segundo
	tween_text.tween_property($Label, "modulate:a", 1.0, 1.0)
	tween_text.tween_property($Label_instructions, "modulate:a", 1.0, 1.0)
	# Logos começam invisíveis
	logo_ufal.modulate = Color(1,1,1,0)
	logo_profbio.modulate = Color(1,1,1,0)

	# Tween para fade-in dos logos
	var tween_logo = create_tween()
	tween_logo.tween_interval(1.0) # atraso de 1 segundo
	tween_logo.tween_property(logo_ufal, "modulate:a", 1.0, 1.0)
	tween_logo.tween_property(logo_profbio, "modulate:a", 1.0, 1.0)
	
	
func _input(event):
	if event.is_action_pressed("ui_accept"): # espaço
		if current_index < cards.size() - 1:
			current_index += 1
			show_card(current_index)
		else:
			get_tree().change_scene_to_file("res://prefabs/main_menu.tscn")
			#queue_free()
	elif event.is_action_pressed("ui_cancel"): # esc
		get_tree().change_scene_to_file("res://prefabs/main_menu.tscn")
		#queue_free()
