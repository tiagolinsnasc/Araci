extends Node2D

func _ready() -> void:
	#Passaros iniciam mudos
	_mute_recursive(self)
	self.visible = false

##Deixa os itens dentro de um nó com o som desabilitado
func _mute_recursive(node: Node) -> void:
	# se for um player de áudio, para o som
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		node.stop()
	
	# percorre os filhos desse nó também
	for sub in node.get_children():
		_mute_recursive(sub)
		
##Reativa o som dos itens dentro de um nó
func _unmute_recursive(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		if node.stream: # só toca se tiver áudio configurado
			node.play()

	for sub in node.get_children():
		_unmute_recursive(sub)
