extends Control

@onready var result_panel = $TextureRect
@onready var progress_bar = $TextureRect/ProgressBar
@onready var flash_rect = $TextureRect/ProgressBar/FlashRect

var thresholds = [0.25, 0.5, 0.75,1.0]
var current_threshold_idx = 0

signal add_reward

func _ready():
	# 게임 시작 시 결과창을 화면 위쪽 밖으로 숨겨둡니다.
	result_panel.position.y = -result_panel.size.y
	result_panel.hide()
	progress_bar.value = 0
	
	flash_rect.modulate.a = 0.0
	
	progress_bar.value_changed.connect(_on_progress_bar_value_changed)
	
# 게임 오버 시 호출할 함수
func show_result_screen(value):
	result_panel.show()
	
	current_threshold_idx = 0
	progress_bar.value = 0
	# 현재 화면(뷰포트)의 크기를 가져옵니다.
	var screen_size = get_viewport_rect().size
	
	# 결과창이 화면 중앙에 오기 위한 목표 Y 좌표를 계산합니다.
	var target_y = (screen_size.y - result_panel.size.y) / 2.0
	
	# Tween 생성
	var tween = create_tween()
	
	# 애니메이션의 가속/감속 곡선 설정 (원하는 느낌에 따라 변경 가능)
	tween.set_trans(Tween.TRANS_BOUNCE) # 바닥에 부딪히듯 통통 튀는 효과
	tween.set_ease(Tween.EASE_OUT)      # 목표 지점에서 효과가 나타나도록 설정
	
	# 1.0초 동안 result_panel의 position:y 값을 target_y로 변화시킵니다.
	tween.tween_property(result_panel, "position:y", target_y, 1.0)
	
	tween.tween_interval(0.5)
	tween.set_trans(Tween.TRANS_SINE) # 바닥에 부딪히듯 통통 튀는 효과
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(progress_bar, "value", value, 1.5)
	tween.tween_callback(on_exit_button)
func _on_progress_bar_value_changed(new_value: float):
	if current_threshold_idx >= thresholds.size():
		
		return
		
	var target_value = progress_bar.max_value * thresholds[current_threshold_idx]
	
	if new_value >= target_value:
		trigger_flash_effect()
		add_reward.emit(thresholds[current_threshold_idx])
		current_threshold_idx += 1

func trigger_flash_effect():
	var flash_tween = create_tween()
	
	flash_tween.tween_property(flash_rect, "modulate:a", 1.0, 0.05)
	flash_tween.tween_property(flash_rect, "modulate:a", 0.0, 0.15)

func on_exit_button():
	$TextureRect/Button.visible = true
	
