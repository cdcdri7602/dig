extends Area2D

@export var move_velocity = 100
var is_room = false
var inputs = {
	"ui_right": Vector2.RIGHT,
	"ui_left": Vector2.LEFT
}

func _ready():
	position = Vector2(108,536.0)

func _physics_process(delta: float):
	if Input.is_key_pressed(KEY_D):
		$AnimatedSprite2D.flip_h = false
		position.x += move_velocity*delta
	if Input.is_key_pressed(KEY_A):
		$AnimatedSprite2D.flip_h = true
		position.x -= move_velocity*delta
	if position.x <= 0:
		position.x = 0
	if position.x >= 950.0 and not is_room:
		position.x = 950.0
	elif position.x >= 2028.0 and is_room:
		position.x = 2028.0
