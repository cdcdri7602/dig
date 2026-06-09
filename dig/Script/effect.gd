extends SubViewportContainer

@onready var sub_viewport = $SubViewport
@onready var cctv_camera = $SubViewport/Camera2D
@onready var noise_color_rect = $SubViewport/CanvasLayer/CctvOverlay

@export var target_map_position: Vector2 = Vector2(4740.0, 235.0)

# [추가] 진행 중인 페이드아웃 Tween을 추적하기 위한 변수
var fade_tween: Tween 

func _ready():
	sub_viewport.world_2d = get_viewport().world_2d
	cctv_camera.global_position = target_map_position
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func play_tv_turn_on_effect():
	pivot_offset = size / 2.0
	scale = Vector2(0.0, 0.0)
	modulate = Color(0.1, 0.1, 0.1, 1.0)
	
	$"../../../Camera2D".enabled = false
	material.set_shader_parameter("progress", 0.0)
	
	var shape_tween = create_tween()
	shape_tween.set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	shape_tween.tween_property(self, "scale", Vector2(1.0, 0.02), 0.12)
	shape_tween.parallel().tween_property(material, "shader_parameter/progress", 0.5, 0.12)
	
	shape_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	shape_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	shape_tween.parallel().tween_property(material, "shader_parameter/progress", 1.0, 0.2)
	
	shape_tween.finished.connect(_on_tv_fully_opened)
	
func _on_tv_fully_opened():
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	# [수정] 새로 생성한 Tween을 fade_tween 변수에 저장합니다.
	fade_tween = create_tween()
	fade_tween.tween_interval(1.0)
	fade_tween.tween_property(noise_color_rect.material, "shader_parameter/fade_alpha", 0.0, 1.0)
	fade_tween.tween_callback(func():
		noise_color_rect.visible = false
	)

func play_tv_turn_off_effect():
	# [추가] 화면이 꺼질 때, 진행 중인 노이즈 페이드아웃 Tween이 있다면 강제로 파괴(Kill)합니다.
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	# 1. 원래 플레이어를 비추던 메인 카메라 다시 활성화
	$"../../../Camera2D".enabled = true
	
	# 2. TV 꺼지는 연출
	var shape_tween = create_tween()
	shape_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	shape_tween.tween_property(self, "scale", Vector2(1.0, 0.02), 0.1)
	shape_tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.1)
	
	shape_tween.finished.connect(_on_tv_fully_closed)

func _on_tv_fully_closed():
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	
	# 4. 다음에 다시 켰을 때 노이즈가 정상적으로 보이도록 상태 강제 초기화
	noise_color_rect.visible = true
	if noise_color_rect.material:
		noise_color_rect.material.set_shader_parameter("fade_alpha", 1.0)
