class_name ExitPortal
extends Node2D


@onready var sprite: Sprite2D = $Sprite
var _t: = 0.0


func trigger_rect() -> Rect2:
	return Rect2(position + Vector2(-5, -20), Vector2(10, 20))


func _process(delta: float) -> void :
	_t += delta
	sprite.frame = int(_t * 10.0) % 6
