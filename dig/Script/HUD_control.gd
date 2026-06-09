extends CanvasLayer

var ui_stage:Control
var ui_main:Control
var ui_upgrade:Control
var camera:Camera2D

var another_UI_on = false

func _ready() -> void:
	ui_stage = $stageUI
	ui_main = $mainUI
	ui_stage.stage_signal.connect(move_to_stage)
	ui_stage.off_stage.connect(off_stage)
	
	
func move_to_stage(value:int):
	Globals.stage_num = value
	get_tree().change_scene_to_file("res://Scene/stage.tscn")
	
func open_stage():
	if another_UI_on:
		return
	another_UI_on = true
	$stageUI.show()
	
func off_stage():
	another_UI_on = false
	$stageUI.hide()
	
	
