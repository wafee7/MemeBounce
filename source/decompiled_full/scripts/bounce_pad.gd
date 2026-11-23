class_name BouncePad
extends Node2D


@onready var sprite: Sprite2D = $Sprite
@onready var burst: CPUParticles2D = $Burst
var _anim_t: = 0.0


func trigger_rect() -> Rect2:
	return Rect2(position + Vector2(1, -6), Vector2(14, 8))


func touches(hitbox: Rect2) -> bool:
	var feet: = Rect2(hitbox.position.x, hitbox.end.y - 2, hitbox.size.x, 2)
	return trigger_rect().intersects(feet)


func fire(loud: bool) -> void :
	_anim_t = 0.0
	sprite.frame = 1
	burst.restart()
	burst.emitting = true
	Game.sfx("bounce", 0.0 if loud else -12.0, 0.08)


func _process(delta: float) -> void :
	_anim_t += delta
	if _anim_t > 0.05 and sprite.frame == 1:
		sprite.frame = 2
	elif _anim_t > 0.25 and sprite.frame == 2:
		sprite.frame = 0
