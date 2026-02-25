extends Control

var cards = [
	preload("res://n_assets/n_cuts/start/instructions.png"),
]

var texts = [
"[u][b]Ações comuns[/b][/u]

[table=2]
[cell][b]Pulo  [/b][/cell][cell]Barra de espaço[/cell]
[cell][b]Andar para frente  [/b][/cell][cell]Seta para direita[/cell]
[cell][b]Andar para trás  [/b][/cell][cell]Seta para esquerda[/cell]
[cell][b]Menu de pausa  [/b][/cell][cell]Esc[/cell]
[/table]

[u][b]Ações especiais[/b][/u]

[table=2]
[cell][b]Informações  [/b][/cell][cell]i (quando estiver em frente e perto de um animal)[/cell]
[cell][b]Chamar pet  [/b][/cell][cell]q (chama ou dispensa o pet)[/cell]
[cell][b]Ataque do pet  [/b][/cell][cell]p (quando em uma distância adequada, manda o pet pegar o inimigo)[/cell]
[cell][b]Super pulo [/b][/cell][cell]segure o w enquanto pula[/cell]
[cell][b]Teletransporte [/b][/cell][cell]t [/cell]
[/table]"

]

var full :Vector2 = Vector2(35, 35)

var positions = [
	full
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
			to_main()
	elif event.is_action_pressed("ui_cancel"): # esc
		to_main()

func to_main():
	get_tree().change_scene_to_file("res://prefabs/main_menu.tscn")
