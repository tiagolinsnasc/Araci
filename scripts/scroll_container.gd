extends ScrollContainer
func _gui_input(event):
	if event is InputEventScreenDrag:
		scroll_vertical -= event.relative.y
