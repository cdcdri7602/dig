extends Control

signal stage_signal
signal off_stage
func _on_stage_1_pressed() -> void:
	emit_signal("stage_signal",$Control.stage)


func _on_off_button_pressed() -> void:
	emit_signal("off_stage")
	$Control.reset(true)
