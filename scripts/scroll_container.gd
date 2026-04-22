extends ScrollContainer
func _gui_input(event):
	if event is InputEventScreenDrag:
		$ScrollContainer.scroll_vertical += -event.relative.y
