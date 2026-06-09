extends TextureRect

@export_group("Move Settings")
@export var slide_duration: float = 1.0
@export_group("Scale Settings")
@export var target_scale: Vector2 = Vector2(1.75, 1.75)
@export var scale_duration: float = 0.5

var is_room1_open = false
var is_room2_open = false
var is_room3_open = false
var is_animating: bool = false
var is_open: bool = false # [추가] 현재 화면이 열려있는지 확인하는 변수
var is_gameover:bool = false

var cam = 1

func _ready():
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	pivot_offset = size / 2.0
	
	var viewport_size = get_viewport_rect().size
	var center_x = (viewport_size.x - size.x) / 2.0
	position = Vector2(center_x, viewport_size.y + 400)
	scale = Vector2.ONE 

func _input(event):
	# [수정] 열기: 애니메이션 중이 아니고, 화면이 닫혀있을 때만 작동
	if event.is_action_pressed("ui_accept") and not is_animating and not is_open and not is_gameover and is_room1_open:
		var viewport_size = get_viewport_rect().size
		var target_position = (viewport_size - size) / 2.0
		start_animation_sequence(target_position)
	
	
	# [추가] 닫기: ESC(ui_cancel) 키를 누르고, 화면이 열려있을 때 작동
	if event.is_action_pressed("ui_cancel") and not is_animating and is_open:
		close_animation_sequence()
	if event.is_action_pressed("move_up") and not is_animating and is_open:
		cam+=1
		cam_change()
	if event.is_action_pressed("move_down") and not is_animating and is_open:
		cam-=1
		cam_change()
func _physics_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_RIGHT) and not is_animating and is_open:
		$SubViewportContainer/SubViewport/Camera2D.global_position.x += 200 * delta
		if $SubViewportContainer/SubViewport/Camera2D.global_position.x >= 6053:
			$SubViewportContainer/SubViewport/Camera2D.global_position.x = 6053	
	if Input.is_key_pressed(KEY_LEFT) and not is_animating and is_open:
		$SubViewportContainer/SubViewport/Camera2D.global_position.x -= 200 * delta
		if $SubViewportContainer/SubViewport/Camera2D.global_position.x <= 4740:
			$SubViewportContainer/SubViewport/Camera2D.global_position.x = 4740
	if Input.is_key_pressed(KEY_E) and not is_animating and is_open:
		print($SubViewportContainer/SubViewport/Camera2D.global_position)
func start_animation_sequence(target_pos: Vector2):
	is_animating = true
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", target_pos, slide_duration)
	
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", target_scale, scale_duration)
	
	tween.chain().tween_callback($SubViewportContainer.play_tv_turn_on_effect)
	
	tween.tween_callback(func():
		is_animating = false
		is_open = true # [추가] 열림 상태로 변경
		print("모든 연출 끝!"))

# [추가] 화면을 닫는 시퀀스
func close_animation_sequence():
	is_animating = true
	
	# 1. TV 끄기 효과 먼저 실행
	$SubViewportContainer.play_tv_turn_off_effect()
	
	var tween = create_tween()
	
	# 2. 크기를 원래대로(Vector2.ONE) 축소
	tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, scale_duration)
	
	# 3. 화면 밑으로 다시 내려가기
	var viewport_size = get_viewport_rect().size
	var center_x = (viewport_size.x - size.x) / 2.0
	var offscreen_pos = Vector2(center_x, viewport_size.y + 400)
	
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", offscreen_pos, slide_duration)
	
	# 4. 종료 처리
	tween.tween_callback(func():
		is_animating = false
		is_open = false # 상태를 닫힘으로 변경
		print("화면 복귀 완료!"))
func cam_change():
	if cam== 4:
		cam = 1
	if cam == 0:
		cam = 3
	if cam == 3 and not is_room3_open:
		cam = 1
	if cam == 2 and not is_room2_open:
		cam = 1
	match cam:
		1:
			$SubViewportContainer/SubViewport/Camera2D.global_position = Vector2(4740.0, 235.0) 
			$SubViewportContainer/SubViewport/CanvasLayer/Label.text ="CAM 1"
		2:
			$SubViewportContainer/SubViewport/Camera2D.global_position = Vector2(4740.0, -837) 
			$SubViewportContainer/SubViewport/CanvasLayer/Label.text ="CAM 2"	
		3:
			$SubViewportContainer/SubViewport/Camera2D.global_position = Vector2(4740.0, -1766.0) 
			$SubViewportContainer/SubViewport/CanvasLayer/Label.text ="CAM 3"
