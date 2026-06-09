extends Resource

class_name UpgradeData

@export var id: String
@export var title: String
@export var description: String
@export var icon: Texture2D
@export var cost: int = 0
@export var old_log:int = 0
@export var stage_1:bool = false
@export var stage_2:bool = false
@export var stage_3:bool = false
@export var prerequisites: Array[String] = []
