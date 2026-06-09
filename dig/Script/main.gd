extends Node2D
var player:Area2D
var camera:Camera2D
var car:Node2D
var once = false



var is_upgradetree_on = false
var is_museum_enter = false
var is_car_enter = false
var is_exit_museum = false
var is_desk_enter = false
var is_room1_enter = false
var is_room2_enter = false
var is_room3_enter = false
var is_room_exit = false
var is_room2_exit = false
var is_room3_exit = false
var is_room = false

func _ready() -> void:
	player = get_node("Player")
	camera = $Camera2D
	car = $Car
	$Control/UpgradeTree/Camera2D.enabled = false
	$HUD/mainUI.on_upgrade_tree.connect(on_upgrade_tree)
	$Control/UpgradeTree.off_upgrade_tree.connect(off_upgrade_tree)
	$Control/UpgradeTree/Control.refresh_money.connect($HUD/mainUI.refresh)

func _physics_process(_delta: float):
	pass
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_E) and not $HUD.another_UI_on and is_car_enter:
		$HUD/stageUI.visible = true
		$HUD.another_UI_on = true
	if(is_museum_enter and Input.is_key_pressed(KEY_E)):
		player.position = Vector2(112,-227.0)
	if(is_exit_museum and Input.is_key_pressed(KEY_E)):
		player.position = Vector2(614.0,536.0)
	if is_desk_enter and Input.is_key_pressed(KEY_E):
		is_upgradetree_on = true
		on_upgrade_tree()
	if is_room1_enter and Input.is_key_pressed(KEY_E):
		is_room = true
		$Player.is_room = true
		player.position = Vector2(1074.0,-1258.0)
		
	if is_room2_enter and Input.is_key_pressed(KEY_E):
		player.position = Vector2(1074.0,-2263.0)
		
	if is_room3_enter and Input.is_key_pressed(KEY_E):
		player.position = Vector2(1074.0,-3160.0)
		
	if is_room_exit and Input.is_key_pressed(KEY_E):
		is_room = false
		$Player.is_room = false
		player.position = Vector2(564.0,-227.0)
	
	if is_room2_exit and Input.is_key_pressed(KEY_E):
		player.position = Vector2(702.0,-1258.0)
		
	if is_room3_exit and Input.is_key_pressed(KEY_E):
		player.position = Vector2(702.0,-2278.0)
		
	if Input.is_key_pressed(KEY_ESCAPE) and is_upgradetree_on:
		off_upgrade_tree()
		is_upgradetree_on =false
		
func _process(_delta: float) -> void:
	camera.zoom = Vector2(2,2)
	camera.position = player.position + Vector2(0,-30)
	if camera.position.x <= 320.0 and not is_room:
		camera.position.x = 320.0
	elif camera.position.x <= 324.0 and is_room:
		camera.position.x = 324.0
		
	if camera.position.x >= 650.0 and not is_room:
		camera.position.x = 650.0
	elif camera.position.x >= 1730.0 and is_room:
		camera.position.x = 1730.0
	
	


func _on_car_area_entered(_area: Area2D) -> void:
	is_car_enter = true
	$Car/ui.visible = true

func _on_car_area_exited(_area: Area2D) -> void:
	is_car_enter = false
	$HUD.another_UI_on = false
	$HUD/stageUI.visible = false
	$HUD/stageUI/Control.reset(true)
	$Car/ui.visible = false
	
func _on_area_2d_area_entered(_area: Area2D) -> void:
	is_museum_enter = true
	$Museum/Sprite2D.visible = true
	
func _on_area_2d_area_exited(_area: Area2D) -> void:
	is_museum_enter = false
	$Museum/Sprite2D.visible = false
	
func on_upgrade_tree():
	if $HUD.another_UI_on:
		$HUD/mainUI.isOpenUpgradeTree = false
		return
	$HUD.another_UI_on = true
	$Control/UpgradeTree.visible = true
	$Control/UpgradeTree/Camera2D.enabled = true
	$Camera2D.enabled = false
	$Car.visible = false
	$Player.visible = false
	$TileMap.visible = false
	$TileMap2.visible = false
	$Museum.visible = false
	$BackGround/MainBackground.visible = false
	$BackGround/UpgradeBackground.visible = true
func off_upgrade_tree():
	$Control/UpgradeTree/Camera2D.position = Vector2(640,360)
	$HUD.another_UI_on = false
	$Control/UpgradeTree.visible = false
	$Control/UpgradeTree/Camera2D.enabled = false
	$Camera2D.enabled = true
	$Car.visible = true
	$Player.visible = true
	$TileMap.visible = true
	$TileMap2.visible = true
	$Museum.visible = true
	$BackGround/MainBackground.visible = true
	$BackGround/UpgradeBackground.visible = false



func _exit_museum(_area: Area2D) -> void:
	is_exit_museum = true
	$Area2D/Sprite2D.visible = true
	

func _not_exit_museum(_area: Area2D) -> void:
	is_exit_museum = false
	$Area2D/Sprite2D.visible = false


func _enter_desk(_area: Area2D) -> void:
	is_desk_enter = true
	$Desk/ui.visible = true
	
func _on_desk_area_exited(_area: Area2D) -> void:
	is_desk_enter = false
	$Desk/ui.visible = false
	off_upgrade_tree()



func _on_room_1_area_entered(area: Area2D) -> void:
	if Globals.level >= 1:
		is_room1_enter = true
		$room1/Sprite2D.visible = true
	



func _on_room_1_area_exited(area: Area2D) -> void:
	is_room1_enter = false
	$room1/Sprite2D.visible = false


func _on_room_exit_area_entered(area: Area2D) -> void:
	is_room_exit = true
	$room_exit/Sprite2D.visible = true


func _on_room_exit_area_exited(area: Area2D) -> void:
	is_room_exit = false
	$room_exit/Sprite2D.visible = false




func _on_room_exit_2_area_entered(area: Area2D) -> void:
	$room_exit2/Sprite2D.visible = true
	is_room2_exit = true

func _on_room_exit_2_area_exited(area: Area2D) -> void:
	$room_exit2/Sprite2D.visible = false
	is_room2_exit = false
	



func _on_room_2_area_entered(area: Area2D) -> void:
	if Globals.level >= 2:
		is_room2_enter = true
		$room2/Sprite2D.visible = true


func _on_room_2_area_exited(area: Area2D) -> void:
	is_room2_enter = false
	$room2/Sprite2D.visible = false


func _on_room_3_area_entered(area: Area2D) -> void:
	if Globals.level >= 3:
		is_room3_enter = true
		$room3/Sprite2D.visible = true


func _on_room_3_area_exited(area: Area2D) -> void:
	is_room3_enter = false
	$room3/Sprite2D.visible = false


func _on_room_exit_3_area_entered(area: Area2D) -> void:
	$room_exit3/Sprite2D.visible = true
	is_room3_exit = true

func _on_room_exit_3_area_exited(area: Area2D) -> void:
	$room_exit3/Sprite2D.visible = false
	is_room3_exit = false
