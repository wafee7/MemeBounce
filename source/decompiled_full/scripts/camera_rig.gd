class_name CameraRig
extends Camera2D


var target: Node2D
var _shake: = 0.0
var _shake_time: = 0.0
var _shake_total: = 0.0
var _look: = 0.0


func setup(p_target: Node2D, bounds: Rect2) -> void :
	target = p_target
	limit_left = int(bounds.position.x)
	limit_top = int(bounds.position.y)
	limit_right = int(bounds.end.x)
	limit_bottom = int(bounds.end.y)
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0


func snap_to_target() -> void :
	if target:
		global_position = target.global_position + Vector2(0, -20)
		reset_smoothing()


func shake(amount: float, duration: float) -> void :
	_shake = maxf(_shake, amount)
	_shake_time = duration
	_shake_total = duration


func _physics_process(delta: float) -> void :
	if target == null:
		return
	var p: = target as Player
	if p and p.state == Player.State.ACTIVE:
		_look = lerpf(_look, p.facing * 18.0, 1.0 - exp(-2.5 * delta))
	global_position = target.global_position + Vector2(_look, -20)
	if _shake_time > 0.0:
		_shake_time -= delta
		var k: = _shake_time / _shake_total
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake * k
	else:
		offset = Vector2.ZERO
