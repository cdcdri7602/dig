extends Node2D

@onready var map_layer:TileMapLayer = $MapLayer
@onready var camera:Camera2D = $Camera2D
@onready var timer:Timer = $Timer
@onready var income_timer:Timer = $IncomeTimer
@onready var reward_ui:Control = $HUD/RewardItem
@onready var coin_sprite = $HUD/Clipboard/Meseum/Sprite2D

@export var protect_sign:PackedScene
@export var stage1_item_img: Texture2D
@export var stage2_item_img: Texture2D
@export var stage3_item_img: Texture2D
var HUD:CanvasLayer

var mine_data:Dictionary = {}  

var stage = {  #스테이지 당 맵 크기 
	1:10,
	2:18,
	3:25
}
var mine = { #스테이지 당 폭탄 수 
	1:10,
	2:30,
	3:100
}

var achievement_var:TextureProgressBar
var result_panel:Control

var value:float

var size_x:int
var size_y:int
var mine_count:int
var max_flag:int
var current_flag:int
var count_broken_mine:int = 0
var count_find_mine:int = 0
var add_time:int = 0
var income:int = 0
var income_sec:int =0 
const TILE_COVER = Vector2i(3, 2)
const TILE_EMPTY = Vector2i(3, 1)
const TILE_MINE  = Vector2i(1, 2)
const TILE_FLAG  = Vector2i(0, 2)
const TILE_MINE_BOOM  = Vector2i(4, 1)
const TILE_MINE_FOUND  = Vector2i(2, 2)
var grid_size : Vector2i
var current_hovered_cell := Vector2i(-1, -1)

var is_time_over := false
var is_all_check = false
var is_auto_flag = false
var is_click = false
var is_first_click := true
var is_up_auto_flag = false
var is_deep_excavation = false
var is_xray_excavation = false
var num1 = 0
var num2 = 0
var protect_mine = 0

var skill:Array = []
var reward_item:Array = []
var revealed_tiles:Array = []

var highlight_node: Node2D

var bounce_height: float = -50.0
var anim_duration: float = 0.5
var original_position: Vector2


func _ready():
	original_position = coin_sprite.position
	coin_sprite.visible = false
	achievement_var = $HUD/result/TextureRect/ProgressBar
	result_panel= $HUD/result
	reward_ui.scale = Vector2.ZERO
	reward_ui.visible = false
	mine_count = mine[Globals.stage_num]
	max_flag = mine_count
	current_flag = 0
	achievement_var.max_value = 100
	achievement_var.min_value = 0
	achievement_var.value = 0
	result_panel.hide()
	size_x = stage[Globals.stage_num]
	size_y = stage[Globals.stage_num]
	grid_size = Vector2i(size_x, size_y)
	num1 = 0
	num2 = 0
	
	result_panel.add_reward.connect(set_reward)
	init_board()
	for i in UpgradeManager.upgrade_list:
		if i == "mine_1":			#발굴 기초1
			protect_mine = 2
		if i == "mine_2":			#발굴 기초2
			protect_mine = 5
		if i == "mine_3":			#발굴 기초2
			protect_mine = 10
		if i == "mine_auto_flag":	#오토 플래깅
			is_auto_flag = true
		if i == "mine_upgrade_auto_flag":		#강화
			is_up_auto_flag = true	
		if i == "mine_deep_excavation":
			is_deep_excavation = true	
		if i == "mine_time_1":
			add_time = 15
		if i == "mine_time_2":
			add_time = 30
		if i == "mine_time_3":
			add_time = 40
		if i == "building_1":
			income_sec = 100
			$HUD/Phone.is_room1_open = true
		if i == "building_2":
			income_sec = 250
			$HUD/Phone.is_room2_open = true
		if i == "building_3":
			income_sec = 500
			$HUD/Phone.is_room3_open = true
			
	if not $HUD/Phone.is_room1_open:
		$HUD/Label.visible = false
		$HUD/Spacebar.visible = false
	if income_sec == 0:
		income_sec = 1
	timer.wait_time = 30 + add_time
			
	@warning_ignore("integer_division")
	camera.position = Vector2(size_x*16/2,size_y*16/2)
	if(Globals.stage_num == 1):
		camera.zoom = Vector2(1.75,1.75)
	elif(Globals.stage_num == 2):
		camera.zoom = Vector2(1.6,1.6)
	elif(Globals.stage_num == 3):
		camera.zoom = Vector2(1.45,1.45) 
	
	
	income+=income_sec
	$HUD/Label2.text = "실시간 티켓 수익 : " + str(income)
	income_timer.start()
	timer.start()
	highlight_node = Node2D.new()
	highlight_node.z_index = 10
	add_child(highlight_node)
	highlight_node.draw.connect(_on_highlight_draw)

func _process(_delta: float):
	$HUD/Control/time.text = "영업 종료까지:"+str(int($Timer.time_left))
	$HUD/flagCount.text = "[img=32x32]res://assets/minesc/TileFlag.png[/img] " + str(max_flag - current_flag) 
	if !is_time_over:
		var mouse_pos = get_local_mouse_position()
		var cell_pos = map_layer.local_to_map(mouse_pos)
		
		if cell_pos != current_hovered_cell:
			current_hovered_cell = cell_pos
			highlight_node.queue_redraw()
			
func init_board():	#보드 초기화
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			map_layer.set_cell(Vector2i(x, y), 0, TILE_COVER)
			
			
func place_mines(first_click_pos: Vector2i):
	is_click = true
	var mines_placed = 0
	while mines_placed < mine_count:
		var pos = Vector2i(randi() % grid_size.x, randi() % grid_size.y)
		# 첫 클릭 위치가 아니고, 아직 지뢰가 없는 곳에 배치
		if pos != first_click_pos and not mine_data.has(pos):
			mine_data[pos] = true
			mines_placed += 1
			
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and !is_time_over:
		# 마우스 위치를 타일 좌표로 변환
		var clicked_pos = map_layer.local_to_map(get_local_mouse_position())
		
		# 클릭한 좌표가 보드 내부인지 확인
		if clicked_pos.x < 0 or clicked_pos.x >= grid_size.x or clicked_pos.y < 0 or clicked_pos.y >= grid_size.y:
			return
			
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_first_click:
				place_mines(clicked_pos)
				is_first_click = false
				
			if clicked_pos in revealed_tiles and is_auto_flag:
				auto_flag(clicked_pos)
			else:
				reveal_tile(clicked_pos)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			toggle_flag(clicked_pos)
			
			
func reveal_tile(start_pos: Vector2i):
	# 처리할 타일들을 담을 큐(배열)
	var queue = [start_pos]
	var current_batch_numbers = []
	var has_zero_revealed = false
	
	while queue.size() > 0:
		var pos = queue.pop_front() # 큐에서 하나를 꺼냄
		
		# 이미 열렸거나 깃발이 있는 경우 건너뜀
		if pos in revealed_tiles or map_layer.get_cell_atlas_coords(pos) == TILE_FLAG:
			continue
			
		revealed_tiles.append(pos)
		
		# 지뢰를 밟은 경우
		if mine_data.has(pos):
			if protect_mine > 0:
				map_layer.set_cell(pos, 0, TILE_MINE_FOUND)
				protect_mine-=1
				current_flag+=1
				var sign_child = protect_sign.instantiate()
				sign_child.position = get_local_mouse_position()
				add_child(sign_child)
				return
			map_layer.set_cell(pos, 0, TILE_MINE_BOOM)
			current_flag +=1
			print("Game Over!")
			#is_time_over = true # 게임 오버 처리
			return
			
		# 주변 지뢰 개수 확인
		var adjacent_mines = count_adjacent_mines(pos)
		
		if adjacent_mines > 0:
			# 숫자 타일 표시
			if(adjacent_mines <= 5):
				map_layer.set_cell(pos, 0, Vector2i(adjacent_mines-1, 0))
			else:
				map_layer.set_cell(pos, 0, Vector2i(adjacent_mines-6, 1))
			current_batch_numbers.append(pos)
		else:
			# 빈 타일인 경우 주변 8칸을 큐에 추가하여 나중에 처리
			has_zero_revealed = true
			map_layer.set_cell(pos, 0, TILE_EMPTY)
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					if dx == 0 and dy == 0: continue
					var neighbor = pos + Vector2i(dx, dy)
					
					# 보드 범위 내에 있고 아직 열리지 않은 타일만 추가
					if neighbor.x >= 0 and neighbor.x < grid_size.x and neighbor.y >= 0 and neighbor.y < grid_size.y:
						if not neighbor in revealed_tiles:
							queue.append(neighbor)
							
		if is_up_auto_flag:
			upgrade_auto_flag(pos)
	if is_deep_excavation and has_zero_revealed:
		var deep_queue = []
		var xray_flag_queue = []
		
		for num_pos in current_batch_numbers:
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					if dx == 0 and dy == 0: 
						continue
					var neighbor = num_pos + Vector2i(dx, dy)
					if neighbor.x >= 0 and neighbor.x < grid_size.x and neighbor.y >= 0 and neighbor.y < grid_size.y:
						if not neighbor in revealed_tiles:
							if not mine_data.has(neighbor):
								if map_layer.get_cell_atlas_coords(neighbor) != TILE_FLAG:
									if not neighbor in deep_queue:
										deep_queue.append(neighbor)
						else:
							if is_xray_excavation and map_layer.get_cell_atlas_coords(neighbor) != TILE_FLAG:
								if not neighbor in xray_flag_queue:
									xray_flag_queue.append(neighbor)
		
		is_deep_excavation = false
		for safe_pos in deep_queue:
			if not safe_pos in revealed_tiles:
				reveal_tile(safe_pos)
				spawn_highlight_effect(safe_pos)
		is_deep_excavation = true
		
		
func count_adjacent_mines(pos: Vector2i) -> int:
	var count = 0
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0: continue
			if mine_data.has(pos + Vector2i(dx, dy)):
				count += 1
	return count
	



func toggle_flag(pos: Vector2i):
	if pos in revealed_tiles:
		return
		
	var current_atlas = map_layer.get_cell_atlas_coords(pos)
	if current_atlas == TILE_COVER :
		if current_flag >= max_flag:
			return
		map_layer.set_cell(pos, 0, TILE_FLAG)
		current_flag += 1
	elif current_atlas == TILE_FLAG:
		map_layer.set_cell(pos, 0, TILE_COVER)
		current_flag -= 1

func count_flaged_boom():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var current_atlas = map_layer.get_cell_atlas_coords(Vector2i(x,y))
			if(current_atlas == TILE_FLAG and mine_data.has(Vector2i(x,y))):
				count_find_mine+=1
			elif(current_atlas == TILE_MINE_BOOM):
				count_broken_mine+=1
			elif(current_atlas == TILE_MINE_FOUND):
				count_find_mine+=1
				

func show_board():
	var count = 0
	var batch_size = 10
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var current_atlas = map_layer.get_cell_atlas_coords(Vector2i(x,y))
			if(!mine_data.has(Vector2i(x,y))):
				map_layer.set_cell(Vector2i(x,y),0,TILE_EMPTY)
			elif(current_atlas == TILE_MINE_BOOM):
				pass
			elif(current_atlas == TILE_FLAG):
				map_layer.set_cell(Vector2i(x,y),0,TILE_MINE_FOUND)
			elif(current_atlas == TILE_MINE_FOUND):
				map_layer.set_cell(Vector2i(x,y),0,TILE_MINE_FOUND)
			else:
				map_layer.set_cell(Vector2i(x,y),0,TILE_MINE)
			if(current_atlas != TILE_EMPTY):
				count += 1
				if count % batch_size == 0:
					await get_tree().create_timer(0.05).timeout # 짧은 대기
	await get_tree().process_frame
				
	result_panel.show()
	result_panel.show_result_screen(value)
	var own_coin = count_find_mine * 50
	var lost_coin = count_broken_mine * 20
	var sum = own_coin - lost_coin + income
	if sum < 0:
		sum = 0
	$HUD/result/TextureRect/RichTextLabel.text = "[img=32x32]res://assets/minesc/TileExploded.png[/img]   " + str(count_broken_mine) + " X 20 = " + str(lost_coin)
	$HUD/result/TextureRect/RichTextLabel2.text = "[img=32x32]res://assets/minesc/TileMine_found.png[/img]   " + str(count_find_mine) + " X 50 = " + str(own_coin)
	$HUD/result/TextureRect/RichTextLabel5.text = "운영 수익 = " + str(income)
	$HUD/result/TextureRect/RichTextLabel6.text = "[img=32x32]res://img/gold.png[/img]   " + str(sum)
	Globals.money += sum
	

func _on_timer_timeout() -> void:
	if $HUD/Phone.is_open:
		$HUD/Phone.close_animation_sequence()
		$HUD/Phone.is_gameover = true
	if !is_click:
		var mines_placed = 0
		while mines_placed < mine_count:
			var pos = Vector2i(randi() % grid_size.x, randi() % grid_size.y)
			# 첫 클릭 위치가 아니고, 아직 지뢰가 없는 곳에 배치
			if not mine_data.has(pos):
				mine_data[pos] = true
				mines_placed += 1
	is_time_over = true
	highlight_node.queue_redraw()
	timer.stop()
	income_timer.stop()
	count_flaged_boom()
	print(count_find_mine)
	print(count_broken_mine)
	value = float(count_find_mine)/float(mine_count) * 100
	if value < 0:
		value = 0
	$HUD/result/TextureRect/Label2.text = str(int(value)) + "%"
	show_board()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/play.tscn")
	Globals.return_play = true
	
	

func set_reward(reward:float):
	match Globals.stage_num:
		1:
			if reward == 1.0:
				if Globals.unlocked_stage == 1:
					Globals.unlocked_stage += 1
				show_reward_ui(Globals.stage_num)
				Globals.stage_clr["stage1"] = true
				Globals.old_log += 4
				num1+=4
			if reward == 0.75:
				num1 += 3
				Globals.old_log += 3
			elif reward == 0.5:
				num1 += 2
				Globals.old_log += 2
			elif reward == 0.25:
				num1 += 1
				Globals.old_log += 1
			
			if num1 > 0:
				$HUD/result/TextureRect/RichTextLabel3.text = ""
				$HUD/result/TextureRect/RichTextLabel3.add_image(ItemManager.get_item("old_log").icon,50,50)
				$HUD/result/TextureRect/RichTextLabel3.append_text(" = " + str(num1))
				
		2:
			if reward == 1.0:
				if Globals.unlocked_stage == 2:
					Globals.unlocked_stage += 1
				show_reward_ui(Globals.stage_num)
				Globals.stage_clr["stage2"] = true
				Globals.old_log += 12
				num1+=12
			if reward == 0.75:
				num1 += 9
				Globals.old_log += 9
			elif reward == 0.5:
				num1 += 6
				Globals.old_log += 6
			elif reward == 0.25:
				num1 += 3
				Globals.old_log += 3
			
			if num1 > 0:
				$HUD/result/TextureRect/RichTextLabel3.text = ""
				$HUD/result/TextureRect/RichTextLabel3.add_image(ItemManager.get_item("old_log").icon,50,50)
				$HUD/result/TextureRect/RichTextLabel3.append_text(" = " + str(num1))
				
		3:
			if reward == 1.0:
				if Globals.unlocked_stage == 3:
					Globals.unlocked_stage += 1
				show_reward_ui(Globals.stage_num)
				Globals.stage_clr["stage3"] = true
				Globals.old_log += 28
				num1+=28
			if reward == 0.75:
				num1 += 21
				Globals.old_log += 21
			elif reward == 0.5:
				num1 += 14
				Globals.old_log += 14
			elif reward == 0.25:
				num1 += 7
				Globals.old_log += 7
			
			if num1 > 0:
				$HUD/result/TextureRect/RichTextLabel3.text = ""
				$HUD/result/TextureRect/RichTextLabel3.add_image(ItemManager.get_item("old_log").icon,50,50)
				$HUD/result/TextureRect/RichTextLabel3.append_text(" = " + str(num1))
				
func auto_flag(pos:Vector2i):
	var adjacent_mines = count_adjacent_mines(pos)
	if adjacent_mines == 0:
		return
		
	var unrevealed_neighbor = []
	var flagged_count = 0
	var exploded_count = 0
	
	for dx in range(-1,2):
		for dy in range(-1,2):
			if dx ==0 and dy ==0:
				continue
			var neighbor = pos + Vector2i(dx,dy)
			
			if neighbor.x >= 0 and neighbor.x < grid_size.x and neighbor.y >= 0 and neighbor.y < grid_size.y:
				var current_atlas = map_layer.get_cell_atlas_coords(neighbor)
				
				if not neighbor in revealed_tiles:
					if current_atlas == TILE_FLAG:
						flagged_count += 1
						
					elif current_atlas == TILE_COVER:
						unrevealed_neighbor.append(neighbor)
				else:
					if current_atlas == TILE_MINE_BOOM or current_atlas == TILE_MINE_FOUND:
						exploded_count +=1
						
	if unrevealed_neighbor.size() + flagged_count +exploded_count == adjacent_mines:
		for target_pos in unrevealed_neighbor:
			toggle_flag(target_pos)
						
	
func upgrade_auto_flag(center_pos: Vector2i):
	auto_flag(center_pos)
	
	for dx in range(-1,2):
		for dy in range(-1,2):
			if dx == 0 and dy == 0:
				continue
			var neighbor = center_pos + Vector2i(dx,dy)
				
			if neighbor.x >= 0 and neighbor.x < grid_size.x and neighbor.y >= 0 and neighbor.y < grid_size.y:
				if neighbor in revealed_tiles:
					auto_flag(neighbor)
	
func spawn_highlight_effect(pos: Vector2i):
	var highlight = ColorRect.new()
	highlight.color = Color(1.0, 1.0, 0.5, 0.7) # 반투명한 노란색 (R, G, B, Alpha)
	
	var tile_size = map_layer.tile_set.tile_size
	highlight.size = Vector2(tile_size)
	
	var local_pos = map_layer.map_to_local(pos)
	highlight.position = local_pos - (Vector2(tile_size) / 2.0)
	map_layer.add_child(highlight)
	
	var tween = create_tween()
	tween.tween_property(highlight, "modulate:a", 0.0, 0.5)
	tween.tween_callback(highlight.queue_free)
	
func _on_highlight_draw():
	if is_time_over or current_hovered_cell == Vector2i(-1, -1):
		return
		
	var tile_size = map_layer.tile_set.tile_size
	var highlight_color = Color(1.0, 1.0, 0.5, 0.3)
	var border_color = Color(1.0, 1.0, 0.0, 0.8)
	
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var target_pos = current_hovered_cell + Vector2i(dx, dy)
			if target_pos.x >= 0 and target_pos.x < grid_size.x and target_pos.y >= 0 and target_pos.y < grid_size.y:
				var local_pos = map_layer.map_to_local(target_pos)
				var rect_pos = local_pos - (Vector2(tile_size) / 2.0)
				var rect = Rect2(rect_pos, tile_size)
				highlight_node.draw_rect(rect, highlight_color, true)
				highlight_node.draw_rect(rect, border_color, false, 2.0)


func show_reward_ui(stage:int):
	reward_ui.visible = true
	reward_ui.scale = Vector2.ZERO
	
	match stage:
		1:
			if Globals.stage_clr["stage1"]:
				return
			$HUD/RewardItem/TextureRect2.texture = stage1_item_img
			$HUD/RewardItem/Label.text = "구석기 시대 유물"
			$HUD/RewardItem/Label2.text = "이제부터 구석기관을\n건설할 수 있습니다."
		2:
			if Globals.stage_clr["stage2"]:
				return
			$HUD/RewardItem/TextureRect2.texture = stage2_item_img
			$HUD/RewardItem/Label.text = "신석기 시대 유물"
			$HUD/RewardItem/Label2.text = "이제부터 신석기관을\n건설할 수 있습니다."
		3:
			if Globals.stage_clr["stage3"]:
				return
			$HUD/RewardItem/TextureRect2.texture = stage3_item_img
			$HUD/RewardItem/Label.text = "청동기 시대 유물"
			$HUD/RewardItem/Label2.text = "이제부터 청동기관을\n건설할 수 있습니다."
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(reward_ui, "scale", Vector2(1, 1), 0.5)
	


func _on_income_timer_timeout() -> void:
	coin_sprite.position = original_position
	coin_sprite.modulate.a = 1.0 
	coin_sprite.visible = true
	var target_position = original_position + Vector2(0, bounce_height)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(coin_sprite, "position", target_position, anim_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(coin_sprite, "modulate:a", 0.0, anim_duration)
	tween.set_parallel(false)
	tween.tween_callback(_on_coin_animation_finished)
	
	income += income_sec
	
	$HUD/Label2.text = "실시간 티켓 수익 : " + str(income)
	
func _on_coin_animation_finished():
	coin_sprite.visible = false
	
