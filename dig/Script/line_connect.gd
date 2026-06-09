extends Control

@export var line_scene: PackedScene
@onready var nodes = get_children()
@onready var up_nodes = get_tree().get_nodes_in_group("upgrade_nodes")
signal refresh_money

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
	var building:int
	var is_build:bool = false
	match upgrade_id:
		"building_1":
			building = 1
			is_build = true
		"building_2":
			building = 2
			is_build = true
		"building_3":
			building = 3
			is_build = true 
	if target_node and Globals.money >= target_node.data.cost and Globals.old_log >= target_node.data.old_log:
		if is_build:
			match building:
				1:
					if target_node.data.stage_1 == Globals.stage_clr["stage1"]:
						Globals.money -= target_node.data.cost
						Globals.old_log -= target_node.data.old_log
						UpgradeManager.upgrade_list.append(upgrade_id)
						Globals.level = 1
						refresh_money.emit()
						refresh_tree()
				2:
					if target_node.data.stage_2 == Globals.stage_clr["stage2"]:
						Globals.money -= target_node.data.cost
						Globals.old_log -= target_node.data.old_log
						UpgradeManager.upgrade_list.append(upgrade_id)
						Globals.level = 2
						refresh_money.emit()
						refresh_tree()
				3:
					if target_node.data.stage_3 == Globals.stage_clr["stage3"]:
						Globals.money -= target_node.data.cost
						Globals.old_log -= target_node.data.old_log
						UpgradeManager.upgrade_list.append(upgrade_id)
						Globals.level = 3
						refresh_money.emit()
						refresh_tree()
		else:
			Globals.money -= target_node.data.cost
			Globals.old_log -= target_node.data.old_log
			UpgradeManager.upgrade_list.append(upgrade_id)
			refresh_money.emit()
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
		
