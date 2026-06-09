extends Panel


func _process(_delta):
	if visible:
		global_position = get_global_mouse_position() + Vector2(15, 15)
