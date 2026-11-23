class_name Door
extends StaticBody2D



const TEXTURES: = [preload("res://assets/sprites/door_a.png"), preload("res://assets/sprites/door_b.png")]
const COLORS: = [Color("#a78bfa"), Color("#60a5fa")]

var channel: = 0
var height: = 24.0
var is_open: = false
var _open_amount: = 0.0
var _shape: CollisionShape2D
var _blocked_by_player: = false

@onready var sparks: CPUParticles2D = $Sparks


func setup(p_channel: int, p_height: float) -> void :
	channel = p_channel
	height = p_height


func _ready() -> void :
	_shape = CollisionShape2D.new()
	var r: = RectangleShape2D.new()
	r.size = Vector2(8, height)
	_shape.shape = r
	_shape.position = Vector2(4, height * 0.5)
	add_child(_shape)
	sparks.color = COLORS[channel]
	sparks.position = Vector2(4, height)


func body_rect() -> Rect2:
	return Rect2(position, Vector2(8, height))



func set_open(o: bool, player_inside: bool) -> void :
	if o != is_open:
		is_open = o
		Game.sfx("door_open" if o else "door_close", -4.0 if o else -8.0)
		sparks.restart()
		sparks.emitting = true
	var want_collision: = not is_open and not player_inside
	if _shape.disabled == want_collision:
		_shape.set_deferred("disabled", not want_collision)


func _process(delta: float) -> void :
	var target: = 1.0 if is_open else 0.0
	var prev: = _open_amount
	_open_amount = move_toward(_open_amount, target, delta * 7.0)
	if prev != _open_amount:
		queue_redraw()
	sparks.position.y = 8.0 + (height - 8.0) * (1.0 - _open_amount)


func _draw() -> void :
	var tex: Texture2D = TEXTURES[channel]
	var visible_h: = (height - 8.0) * (1.0 - _open_amount)

	var y: = 8.0
	var offset: = fmod((height - 8.0) - visible_h, 8.0)
	while y < 8.0 + visible_h:
		var h: = minf(8.0, 8.0 + visible_h - y)
		draw_texture_rect_region(tex, Rect2(0, y, 8, h), Rect2(0, offset, 8, h))
		y += h
		offset = 0.0
	draw_texture_rect_region(tex, Rect2(0, 0, 8, 8), Rect2(0, 8, 8, 8))
