extends Control

@onready var rec_dot = $ColorRect
@onready var rec_label = $Label

func _ready():
	# Tween을 생성하고 무한 반복(set_loops)되도록 설정합니다.
	var tween = create_tween().set_loops()
	
	# 0.8초마다 텍스트를 껐다 켜는 함수를 실행하고 대기합니다.
	tween.tween_callback(toggle_rec_visibility)
	tween.tween_interval(0.8)

# 깜빡임(Visible 켜기/끄기)을 처리하는 함수
func toggle_rec_visibility():
	# 현재 보이는 상태의 반대값(보이면 숨김, 숨겨져있으면 보임)을 적용합니다.
	rec_dot.visible = not rec_dot.visible
	rec_label.visible = not rec_label.visible
