extends ColorRect

var threshold = 0.0
@onready var rect: ColorRect = $"."

func _process(_delta: float) -> void:
	if rect.material:
		rect.material.set_shader_parameter("threshold", threshold)
