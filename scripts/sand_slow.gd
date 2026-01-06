extends Area2D

var initial_speed := 0.0
var inicial_jump := 0.0
var inicial_jump_velocity := 0.0

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Araci":
		
		if not Globals.flag_stay_on_sand:
			#Arquivo de icone de areia
			const SAND_ICON = preload("uid://dessbxf3mnpjo")
			Globals.show_side_mensage("Você está em zona de desertificação. A areia reduz sua velocidade e capacidade de pulo!", SAND_ICON, 10.0)
			Globals.flag_stay_on_sand = true
		
		print("Araci na areia fofa!")
		
		#Guarda valores iniciais
		initial_speed = body.max_speed
		inicial_jump = body.jump_height
		inicial_jump_velocity = body.jump_velocity
		
		body.max_speed = body.max_speed/2
		body.jump_height = body.jump_height/5
		body.jump_velocity = body.jump_velocity/2
		print("Velocidade em:"+str(body.max_speed))
		print("Altura do pulo em:"+str(body.jump_height ))
		

func _on_body_exited(body: Node2D) -> void:
		body.max_speed = initial_speed
		body.jump_height = inicial_jump
		body.jump_velocity = inicial_jump_velocity
