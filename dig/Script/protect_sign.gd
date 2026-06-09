extends Label
func _ready():
	play_flaoting_animation()
	
func play_flaoting_animation():
	var tween = create_tween()
	
	tween.set_parallel(true)
	
	
	var target_position = position + Vector2(0,-30)
	tween.tween_property(self,"position",target_position,1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_callback(self.queue_free)
