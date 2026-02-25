extends CanvasLayer

@onready var mobile_controls: CanvasLayer = $"."

func _ready():
	# Verifica se o dispositivo tem touchscreen
	if DisplayServer.is_touchscreen_available():
		mobile_controls.show()
	else:
		mobile_controls.hide()
