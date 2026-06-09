extends Camera2D

var zoom_min = Vector2(0.5, 0.5)
var zoom_max = Vector2(2.0, 2.0)
var zoom_speed = Vector2(0.1, 0.1)
var is_dragging = false


func _unhandled_input(event):
	pass
#	if event is InputEventMouseButton:
#		if event.button_index == MOUSE_BUTTON_LEFT:
#			is_dragging = event.pressed
#	elif event is InputEventMouseMotion and is_dragging:
#		position -= event.relative * zoom
#	
#	if event is InputEventMouseButton and event.pressed:
#		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
	#		zoom -= zoom_speed
	#	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
	#		zoom += zoom_speed
	#	zoom = zoom.clamp(zoom_min, zoom_max)
