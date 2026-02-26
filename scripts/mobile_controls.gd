extends CanvasLayer

@onready var mobile_controls: CanvasLayer = $"."

func _ready():
	print("Carregou mobile HUD")
	
	#Conecta um sinal, em um script global para atualizar o hud mobile
	EventBus.connect("update_mobile_hud", Callable(self, "update_buttons"))
	
	# Verifica se o dispositivo tem touchscreen
	if DisplayServer.is_touchscreen_available():
		mobile_controls.show()
	else:
		mobile_controls.hide()
	

##Atualiza a visibilidade dos botões
func update_buttons():
	print("Atualizou botões no touch!")
	if !DisplayServer.is_touchscreen_available():
		return
		
	# Superpulo
	if Globals.can_super_jump():
		$Control/HBoxContainer/superjump_but.show()
	else:
		$Control/HBoxContainer/superjump_but.hide()

	# Teleporte
	if Globals.can_teleport():
		$Control/HBoxContainer/teleport_but.show()
	else:
		$Control/HBoxContainer/teleport_but.hide()

	# Pet
	if Globals.flag_pw_feroz_enable:
		$Control/HBoxContainer/call_pet_but.show()
		$Control/HBoxContainer/atack_pet_but.show()
	else:
		$Control/HBoxContainer/call_pet_but.hide()
		$Control/HBoxContainer/atack_pet_but.hide()
