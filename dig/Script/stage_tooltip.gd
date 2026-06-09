extends Control

@export var tooltip:PackedScene
@export var percent:int
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)



func _on_mouse_entered():
	var tool = tooltip.instantiate()
	add_child(tool)
	var labels = tool.get_child(0).get_children()
	
	match Globals.stage_num:
		1:	
			labels[0].text = str(percent)+"% 달성 시"
			if percent == 25:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 1")
			if percent == 50:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 2")
			if percent == 75:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 3")
			if percent == 100:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 4\n")
				labels[1].add_text("유물 제공")
		2:
			labels[0].text = str(percent)+"% 달성 시"
			if percent == 25:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 3")
			if percent == 50:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 6")
			if percent == 75:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 9")
			if percent == 100:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 12\n")
				labels[1].add_text("유물 제공")
		3:
			labels[0].text = str(percent)+"% 달성 시"
			if percent == 25:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 7")
			if percent == 50:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 14")
			if percent == 75:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 21")
			if percent == 100:
				labels[1].add_image(ItemManager.get_item("old_log").icon,50,50)
				labels[1].add_text(" = 28\n")
				labels[1].add_text("유물 제공")
func _on_mouse_exited():
	get_child(0).queue_free()
