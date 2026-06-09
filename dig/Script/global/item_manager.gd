extends Node

var item_database:Dictionary = {}

func _ready() -> void:
	init_database()

func init_database():
		item_database = {
			"old_log" : preload("res://Resource/upgradeResource/old_log.tres"),
		}
		
		
func get_item(id:String)->Itemdata:
	if item_database.has(id):
		return item_database[id]
	return null
	
