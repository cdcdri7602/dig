extends Control

@export var line_scene: PackedScene
@onready var nodes = get_children()
@onready var up_nodes = get_tree().get_nodes_in_group("upgrade_nodes")
signal refresh_price

func _ready():
	draw_connections()
	for node in nodes:
		node.upgrade_requested.connect(_on_upgrade_requested)
	refresh_tree()
	
func draw_connections():
	var upgrade_nodes = []
	
	for child in nodes:
		if child is TextureButton and child.get("data") != null and not child.state == "locked" :
			upgrade_nodes.append(child)
		if child is Line2D:
			queue_free()
	for node in upgrade_nodes:
		for req_id in node.data.prerequisites:
			var req_node = _find_node_by_id(upgrade_nodes, req_id)
			if req_node:
				var line = line_scene.instantiate()
				add_child(line)
				move_child(line, 0)
				
				var start_pos = req_node.position + (req_node.size / 2)
				var end_pos = node.position + (node.size / 2)
				
				line.add_point(start_pos)
				line.add_point(end_pos)
				
func _find_node_by_id(node_list: Array, id: String) -> TextureButton:
	for n in node_list:
		if n.data.id == id:
			return n
	return null


func _on_upgrade_requested(upgrade_id: String):
	var target_node = null
	for node in nodes:
		if node.data.id == upgrade_id:
			target_node = node
			break
			
	if target_node and Globals.money >= target_node.data.cost and Globals.old_log >= target_node.data.old_log:
		Globals.money -= target_node.data.cost
		Globals.old_log -= target_node.data.old_log
		UpgradeManager.upgrade_list.append(upgrade_id)
		refresh_price.emit()
		refresh_tree()
	
	
func refresh_tree():
	for node in nodes:
		var id = node.data.id
		var prereqs = node.data.prerequisites
		
		if id in UpgradeManager.upgrade_list:
			node.state = "unlocked"
			node.visible = true
			draw_connections()
		else:
			var can_unlock = true
			for req in prereqs:
				if req not in UpgradeManager.upgrade_list:
					can_unlock = false
					break
			if can_unlock:
				node.state = "available"
				node.visible = true
				draw_connections()
			else:
				node.state = "locked"
		node.update_visuals()
		
