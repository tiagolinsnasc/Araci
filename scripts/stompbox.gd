extends Area2D

@onready var player = get_parent()
##Não interfere no Player, só chama a função stomped() no inimigo. O inimigo decide o que fazer (morrer, animar, etc.)
func _on_body_entered(body: Node2D) -> void:
	print("Encostou em stopmbox!")
	if body.has_method("stomped"):
		body.stomped()
