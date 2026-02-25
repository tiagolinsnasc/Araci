extends CanvasLayer

@onready var resume_btn: Button = $menu_holder/resume_btn
@onready var inicio_btn: Button = $menu_holder/inicio_btn
@onready var confirm_dialog: ConfirmationDialog = $ConfirmResetDialog

var is_opening_pause: bool = false  # Flag para prevenir ativação imediata

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	resume_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	confirm_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# CRÍTICO: Desabilita a resposta padrão do dialog ao ESC
	confirm_dialog.set_flag(Window.FLAG_POPUP, false)
	
	# Conecta sinais para controlar o fechamento manual
	confirm_dialog.canceled.connect(_on_dialog_canceled)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Se o dialog está visível, fecha ele em vez de mexer no pause
		if confirm_dialog.visible:
			confirm_dialog.hide()
			get_viewport().set_input_as_handled()
			return
		
		if visible:
			# Fechando o menu de pause (mesma lógica do botão Resume)
			_on_resume_btn_pressed()
		else:
			# Abrindo o menu de pause
			visible = true
			get_tree().paused = true
			is_opening_pause = true
			resume_btn.grab_focus()
			# Aguarda um frame antes de permitir interações
			await get_tree().process_frame
			is_opening_pause = false
		
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	# Captura qualquer ui_cancel que escape do _input
	if event.is_action_pressed("ui_cancel") and visible:
		get_viewport().set_input_as_handled()

func _on_resume_btn_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_inicio_btn_pressed() -> void:
	# Previne abertura se ainda estamos no frame de abertura do pause
	if is_opening_pause:
		return
	
	# Remove foco dos botões antes de abrir dialog
	if inicio_btn.has_focus():
		inicio_btn.release_focus()
	
	confirm_dialog.popup_centered()
	
	# Foca no botão "Cancelar" do dialog ao invés do "OK"
	await get_tree().process_frame
	var cancel_btn = confirm_dialog.get_cancel_button()
	if cancel_btn:
		cancel_btn.grab_focus()

func _on_dialog_canceled() -> void:
	# Retorna foco para o menu de pause
	resume_btn.grab_focus()

func _on_confirm_reset_dialog_confirmed() -> void:
	get_tree().paused = false
	
	# Reinicia o jogo completamente (Godot 4 syntax)
	OS.create_process(OS.get_executable_path(), [])
	get_tree().quit()

#Ações do botões de touch
func _on_resume_but_pressed() -> void:
	_on_resume_btn_pressed()

func _on_init_but_pressed() -> void:
	_on_inicio_btn_pressed()

func _on_quit_but_pressed() -> void:
	_on_quit_btn_pressed()
