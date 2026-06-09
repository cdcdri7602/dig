extends Control

@onready var map = $BigMap
@onready var line = $Line2D
@onready var desc_panel = $Panel
@onready var title_label = $Panel/Label
@onready var desc_label = $Panel/Label2

var original_line_points: PackedVector2Array
var stage: int
var is_stage_open: bool = false
var is_working = false

var ord_map_pos: Vector2

var current_region: Control = null
var regions_data: Dictionary = {}
var spots_data: Dictionary = {}

var blink_tween: Tween
var move_tween: Tween
var ui_tween: Tween
var spot_blink_tween: Tween


func _ready() -> void:
	map.pivot_offset = Vector2.ZERO
	
	original_line_points = line.points.duplicate()
	line.clear_points()
	
	desc_panel.scale = Vector2(1, 0)
	desc_panel.modulate.a = 0.0
	
	ord_map_pos = map.position
	
	# ==========================================
	# 🌟 [설정부] 해금 조건(req_stage) 추가 등록
	# setup_region(노드, 열리는_스테이지)
	# setup_spot(부모지역, 스팟노드, 열리는_스테이지, 제목, 내용)
	# ==========================================
	
	# 1. 경기도 지역 (1스테이지부터 열림)
	setup_region($Gyeonggi,1)
	# 경기도 안의 자식들 등록 (원하는 만큼 무한 추가 가능!)
	setup_spot($Gyeonggi, $Gyeonggi/stage1, 1, "경기도 연천 전곡리", "맵 크기: 10 X 10\n총 유물 갯수 10개\n\n보상 아이템\n25% 달성: 낡은 목재 1개\n50% 달성: 낡은 목재 2개\n75% 달성: 낡은 목재 3개\n100% 달성: 구석기 유물,낡은 목재 4개")
	
	# 2. 경상도 지역 등록
	setup_region($Gyeongsang,2)
	# 경상도 안의 자식 등록
	setup_spot($Gyeongsang, $Gyeongsang/stage2, 2, "김천 송죽리 유적", "맵 크기: 15 X 15\n총 유물 갯수 30개\n\n보상 아이템\n25% 달성: 낡은 목재 3개\n50% 달성: 낡은 목재 6개\n75% 달성: 낡은 목재 9개\n100% 달성: 신석기 유물,낡은 목재 12개")
	setup_spot($Gyeongsang, $Gyeongsang/stage3, 3, "경주 황성동 유적", "맵 크기: 25 X 25\n총 유물 갯수 100개\n\n보상 아이템\n25% 달성: 낡은 목재 7개\n50% 달성: 낡은 목재 14개\n75% 달성: 낡은 목재 21개\n100% 달성: 청동기 유물,낡은 목재 28개")
	
	start_blinking()

func setup_region(region_node: Control, req_stage: int):
	region_node.pivot_offset = Vector2.ZERO
	regions_data[region_node] = {
		"ord_pos": region_node.position,
		"spots": [],
		"req_stage": req_stage # 지역 해금 조건 저장
	}
	if not region_node.gui_input.is_connected(_on_region_gui_input):
		region_node.gui_input.connect(_on_region_gui_input.bind(region_node))

func setup_spot(region_node: Control, spot_node: TextureRect, req_stage: int, title: String, desc: String):
	regions_data[region_node]["spots"].append(spot_node)
	spots_data[spot_node] = {
		"req_stage": req_stage, # 자식 유적지 해금 조건 저장
		"title": title,
		"desc": desc
	}
	spot_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not spot_node.gui_input.is_connected(_on_spot_gui_input):
		spot_node.gui_input.connect(_on_spot_gui_input.bind(spot_node))

func start_blinking():
	if blink_tween: blink_tween.kill()
	blink_tween = create_tween().set_loops()
	blink_tween.tween_method(set_all_regions_color, Color.WHITE, Color.RED, 0.5)
	blink_tween.tween_method(set_all_regions_color, Color.RED, Color.WHITE, 0.5)

func set_all_regions_color(color: Color):
	for r_node in regions_data.keys():
		if is_instance_valid(r_node):
			# 🚨 조건 통과: 깜빡이는 색상 적용
			if regions_data[r_node]["req_stage"] <= Globals.unlocked_stage:
				r_node.modulate = color
			# 🚨 조건 미달 (잠김): 어두운 회색으로 멈춤
			else:
				r_node.modulate = Color(1, 1, 1)

func _on_region_gui_input(event: InputEvent, node: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_working and not is_stage_open:
		
		# 🚨 잠긴 지역 클릭 방지
		if regions_data[node]["req_stage"] > Globals.unlocked_stage:
			print("아직 해금되지 않은 지역입니다!")
			return
			
		current_region = node
		
		for r_node in regions_data.keys():
			if is_instance_valid(r_node):
				r_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
		is_stage_open = true
		is_working = true
		start_transition_animation()

func start_transition_animation():
	if blink_tween: blink_tween.kill()
	set_all_regions_color(Color.WHITE) # 해금된 것만 하얗게, 잠긴 건 계속 어둡게 유지됨
	
	if move_tween: move_tween.kill()
		
	move_tween = create_tween().set_parallel(true)
	move_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	var target_map_pos = Vector2(100.0, 150.0) 
	var map_target_scale = 0.25 
	var zoom_scale = 2.0 
	
	move_tween.tween_property(map, "position", target_map_pos, 1.0)
	move_tween.tween_property(map, "scale", Vector2(map_target_scale, map_target_scale), 1.0)
	
	for r_node in regions_data.keys():
		if is_instance_valid(r_node):
			if r_node == current_region:
				var screen_center = get_viewport_rect().size / 2.0
				var center_pos = screen_center - (r_node.size * zoom_scale / 2.0)
				move_tween.tween_property(r_node, "position", center_pos, 1.0)
				move_tween.tween_property(r_node, "scale", Vector2(zoom_scale, zoom_scale), 1.0)
			else:
				var r_ord_pos = regions_data[r_node]["ord_pos"]
				var relative_distance = r_ord_pos - ord_map_pos 
				var target_pos = target_map_pos + (relative_distance * map_target_scale)
				move_tween.tween_property(r_node, "position", target_pos, 1.0)
				move_tween.tween_property(r_node, "scale", Vector2(map_target_scale, map_target_scale), 1.0)
	
	move_tween.chain().tween_callback(ready_to_click_spot)

func ready_to_click_spot():
	is_working = false 
	if current_region == null: return
	
	var spots = regions_data[current_region]["spots"]
	for spot in spots:
		if is_instance_valid(spot):
			# 🚨 해금된 스팟만 클릭할 수 있게 마우스 잠금 해제
			if spots_data[spot]["req_stage"] <= Globals.unlocked_stage:
				spot.mouse_filter = Control.MOUSE_FILTER_STOP
			else:
				spot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
	if spot_blink_tween: spot_blink_tween.kill()
	spot_blink_tween = create_tween().set_loops()
	
	spot_blink_tween.tween_method(set_active_spots_color, Color.WHITE, Color.RED, 0.5)
	spot_blink_tween.tween_method(set_active_spots_color, Color.RED, Color.WHITE, 0.5)

func set_active_spots_color(color: Color):
	if current_region == null: return
	var spots = regions_data[current_region]["spots"]
	for spot in spots:
		if is_instance_valid(spot):
			# 🚨 해금된 스팟만 깜빡임 적용
			if spots_data[spot]["req_stage"] <= Globals.unlocked_stage:
				spot.modulate = color
			# 🚨 잠긴 스팟은 어두운 회색 유지
			else:
				spot.modulate = Color(1, 1, 1)

func _on_spot_gui_input(event: InputEvent, spot: TextureRect) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_working:
		
		# 🚨 잠긴 스팟 클릭 방지
		if spots_data[spot]["req_stage"] > Globals.unlocked_stage:
			print("아직 해금되지 않은 유적지입니다!")
			return
			
		is_working = true
		
		var data = spots_data[spot]
		stage = data["req_stage"] # 스테이지 값 저장
		title_label.text = data["title"]
		desc_label.text = data["desc"]
		
		if spot_blink_tween: spot_blink_tween.kill()
		
		var spots = regions_data[current_region]["spots"]
		for s in spots:
			if is_instance_valid(s):
				# 잠긴 스팟은 계속 회색 유지, 열린 건 하얀색 복구
				s.modulate = Color.WHITE if spots_data[s]["req_stage"] <= Globals.unlocked_stage else Color(1, 1, 1)
				s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		if original_line_points.size() > 0:
			var spot_center_global = spot.global_position + (spot.size * spot.scale / 2.0)
			original_line_points[0] = line.to_local(spot_center_global)
			
		show_description()


func go_to_next_stage():
	# 만약 맵 대기 상태에서 함수가 호출되었다면, 새 지역이 깜빡이도록 새로고침
	if not is_stage_open:
		start_blinking()

func reset(off: bool):
	is_stage_open = false
	
	if spot_blink_tween: spot_blink_tween.kill()
	
	for r_node in regions_data.keys():
		if is_instance_valid(r_node):
			var spots = regions_data[r_node]["spots"]
			for spot in spots:
				if is_instance_valid(spot):
					spot.modulate = Color.WHITE if spots_data[spot]["req_stage"] <= Globals.unlocked_stage else Color(1, 1, 1)
					spot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if off:
		if blink_tween: blink_tween.kill()
		if move_tween: move_tween.kill()
		if ui_tween: ui_tween.kill()
		
		desc_panel.modulate.a = 0.0
		desc_panel.scale = Vector2(1, 0)
		
		line.modulate.a = 0.0
		line.clear_points()
		
		map.position = ord_map_pos
		map.scale = Vector2(1.0, 1.0)
		
		for r_node in regions_data.keys():
			if is_instance_valid(r_node):
				r_node.position = regions_data[r_node]["ord_pos"]
				r_node.scale = Vector2(1.0, 1.0)
				r_node.modulate = Color.WHITE if regions_data[r_node]["req_stage"] <= Globals.unlocked_stage else Color(1, 1, 1)
				r_node.mouse_filter = Control.MOUSE_FILTER_STOP if regions_data[r_node]["req_stage"] <= Globals.unlocked_stage else Control.MOUSE_FILTER_IGNORE
				
		current_region = null
		is_working = false
		
		start_blinking()
		
	else:
		if ui_tween: ui_tween.kill()
		
		if desc_panel.modulate.a > 0.1:
			ui_tween = create_tween()
			ui_tween.tween_property(desc_panel, "modulate:a", 0.0, 0.2)
			ui_tween.parallel().tween_property(desc_panel, "scale", Vector2(1, 0), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			ui_tween.tween_method(_draw_line, 1.0, 0.0, 0.4)
			ui_tween.chain().tween_callback(play_reset_map_anim)
		else:
			play_reset_map_anim()

func play_reset_map_anim():
	if move_tween: move_tween.kill()
	move_tween = create_tween().set_parallel(true)
	move_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	move_tween.tween_property(map, "position", ord_map_pos, 1.0)
	move_tween.tween_property(map, "scale", Vector2(1.0, 1.0), 1.0)
	
	for r_node in regions_data.keys():
		if is_instance_valid(r_node):
			var ord_pos = regions_data[r_node]["ord_pos"]
			move_tween.tween_property(r_node, "position", ord_pos, 1.0)
			move_tween.tween_property(r_node, "scale", Vector2(1.0, 1.0), 1.0)
			
	move_tween.chain().tween_callback(start_blinking)
	move_tween.chain().tween_callback(mouse_reset)
	move_tween.chain().tween_callback(block)

func _unhandled_input(event: InputEvent) -> void:
	if is_stage_open and Input.is_key_pressed(KEY_ESCAPE) and not is_working:
		is_working = true
		reset(false)

func mouse_reset():
	for r_node in regions_data.keys():
		if is_instance_valid(r_node):
			# 🚨 맵 초기화 시, 해금된 지역만 다시 마우스 잠금 해제
			if regions_data[r_node]["req_stage"] <= Globals.unlocked_stage:
				r_node.mouse_filter = Control.MOUSE_FILTER_STOP
			else:
				r_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	current_region = null 

func block():
	is_working = false

func show_description():
	line.modulate.a = 1.0
	
	if ui_tween: ui_tween.kill()
	ui_tween = create_tween()
	
	ui_tween.tween_method(_draw_line, 0.0, 1.0, 0.4)
	ui_tween.tween_property(desc_panel, "modulate:a", 1.0, 0.2)
	ui_tween.parallel().tween_property(desc_panel, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	ui_tween.chain().tween_callback(block)

func _draw_line(progress: float):
	line.clear_points()
	if original_line_points.size() < 2: return
		
	var total_length = 0.0
	var segment_lengths = []
	
	for i in range(original_line_points.size() - 1):
		var length = original_line_points[i].distance_to(original_line_points[i+1])
		segment_lengths.append(length)
		total_length += length
		
	var target_length = total_length * progress
	var current_length = 0.0
	line.add_point(original_line_points[0])
	
	for i in range(original_line_points.size() - 1):
		var seg_len = segment_lengths[i]
		if current_length + seg_len <= target_length:
			line.add_point(original_line_points[i+1])
			current_length += seg_len
		else:
			var leftover = target_length - current_length
			var ratio = leftover / seg_len
			var interpolated_point = original_line_points[i].lerp(original_line_points[i+1], ratio)
			line.add_point(interpolated_point)
			break
