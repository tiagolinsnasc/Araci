extends Control

var cards = [
	preload("res://n_assets/n_cuts/start/credit_bg.png"),
	#preload("res://n_assets/n_cuts/final/s2.png"),
]

var texts = [
	"
	[b]Desenvolvedor:[/b]  Thiago Lins do Nascimento
	[b]Narrativa principal:[/b] Thiago Lins do Nascimento
	[b]Histórias iniciais:[/b] Turma do 1º ANO A do curso técnico de Redes de Computadores do Ensino Médio da ETE Francisco de Matos Sobrinho (2025)
	
	[b]Recursos visuais:[/b] Uso de IA https://copilot.microsoft.com/ e poteriores adaptações e alterações. Universal LPC Spritesheet Generator.
	
	[b]Recursos auditivos:[/b] Uso de IA: https://suno.com/me e biblioteca do Pixabay (https://pixabay.com/)
	
	[b]Edição de imagens:[/b] Gimp, krita e Inkscape
	[b]Edição de sons:[/b] Audacity
	
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
