extends Control

func _ready():
	# Conectar sinais dos botões
	$VBoxContainer/but_init.connect("pressed", Callable(self, "_on_start_pressed"))
	$VBoxContainer/but_load.connect("pressed", Callable(self, "_on_load_pressed"))
	$VBoxContainer/but_instructions.connect("pressed", Callable(self, "_on_load_instructions"))
	$VBoxContainer/but_sair.connect("pressed", Callable(self, "_on_quit_pressed"))
	$VBoxContainer/but_credits.connect("pressed", Callable(self, "_on_credits_pressed"))


	# Som ambiente (se quiser tocar música de fundo)
	if $AudioStreamPlayer.stream:
		$AudioStreamPlayer.play()

func _on_start_pressed():
	# Para o som ambiente
	$AudioStreamPlayer.stop()
	# Troca para a cena antes de iniciar o jogo (cutscene)
	get_tree().change_scene_to_file("res://prefabs/cutscene_start_card_sequence.tscn")
	print("Iniciar o jogo")

func _on_load_pressed():
	$AudioStreamPlayer.stop()
	# Aqui você vai implementar o sistema de salvamento depois
	print("Carregar jogo - ainda não implementado")

func _on_credits_pressed():
	$AudioStreamPlayer.stop()
	# Troca para a cena de créditos (exemplo: Credits.tscn)
	print("Créditos")
	get_tree().change_scene_to_file("res://prefabs/cutscene_credit_card_sequence.tscn")

func _on_load_instructions():
	print("Instruções")
	get_tree().change_scene_to_file("res://prefabs/cutscene_instructions_card.tscn")
func _on_quit_pressed():
	get_tree().quit()
