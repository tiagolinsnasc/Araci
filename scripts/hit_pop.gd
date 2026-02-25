extends Area2D


@export var dialog_texts : Array[String] = []
@export var offset_position : Vector2 = Vector2(0,-20)

var unique_view = true
var active = true

func _on_body_entered(_body: Node2D) -> void:
	if unique_view and active:
		DialogManager.start_dialog(dialog_texts, global_position)
		active = false	
	elif !unique_view:
		DialogManager.start_dialog(dialog_texts, global_position)
	
