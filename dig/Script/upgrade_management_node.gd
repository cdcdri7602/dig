extends TextureButton

@export var data: UpgradeData
@export var tooltip:PackedScene

var state: String = "locked" # "locked", "available", "unlocked"

signal upgrade_requested(upgrade_id)



func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	texture_normal = data.icon
	pressed.connect(_on_pressed)
	update_visuals()

	if state == "locked":
		visible = false
		
		
func _on_pressed():
	if state == "available":
		upgrade_requested.emit(data.id)
		update_visuals()

func update_visuals():
	match state:
		"locked":
			modulate = Color(0.3, 0.3, 0.3) # 어둡게 처리
			disabled = true
		"available":
			modulate = Color(1, 1, 1) # 원래 색상
			disabled = false
			# 여기에 반짝이는 이펙트를 추가할 수 있습니다.
		"unlocked":
			modulate = Color(1, 0.8, 0.2) # 금색으로 하이라이트
			disabled = true # 이미 해금되었으므로 다시 누를 수 없게 함

func _on_mouse_entered():
	var tool = tooltip.instantiate()
	add_child(tool)
	var labels = tool.get_child(0).get_children();
	labels[0].text = data.title
	labels[1].text = "설명: " + data.description
	labels[3].text = str(data.cost)

func _on_mouse_exited():
	get_child(0).queue_free()
