extends CanvasLayer

@onready var color_rect: ColorRect = $color_rect

func _ready():
	show_new_scene()
	
func change_scene(path: String, delay: float = 1.5) -> void:
	var scene_transiction = get_tree().create_tween()
	scene_transiction.tween_property(color_rect, "threshold", 1.0, 0.5).set_delay(delay)

	scene_transiction.finished.connect(func():
		var result = get_tree().change_scene_to_file(path)
		if result == OK:
			queue_free()
		else:
			push_error("Falha ao carregar cena: %s" % path)
	)

func show_new_scene() -> void:
	var show_transiction = get_tree().create_tween()
	show_transiction.tween_property(color_rect, "threshold", 0.0, 0.5).from(1.0)

	show_transiction.finished.connect(func():
		print("Transição de entrada concluída")
	)
